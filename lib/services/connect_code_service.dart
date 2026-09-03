import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class ConnectCodeService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generates a standardized Callyzer Biz format connect code:
  /// [3-LETTER-PREFIX]-[4-DIGITS]-[4-DIGITS], e.g. ROH-3453-2342 or KUS-3926-0820
  static String generateCode(String name) {
    final clean = name.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    String prefix;
    if (clean.length >= 3) {
      prefix = clean.substring(0, 3);
    } else if (clean.isNotEmpty) {
      prefix = '${clean}XXX'.substring(0, 3);
    } else {
      prefix = 'TAK';
    }

    final random = Random.secure();
    final part1 = 1000 + random.nextInt(9000); // 1000 - 9999
    final part2 = 1000 + random.nextInt(9000); // 1000 - 9999

    return '$prefix-$part1-$part2';
  }

  /// Search Firestore users and devices by phone number variations
  static Future<Map<String, dynamic>?> findUserByPhone(String rawPhone) async {
    try {
      final cleanDigits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanDigits.length < 8) return null;
      final last10 = cleanDigits.length >= 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;

      final phoneVariations = [
        rawPhone.trim(),
        cleanDigits,
        '+91$last10',
        '+91 $last10',
        last10,
      ];

      // 1. Check users collection by doc ID usr_$cleanDigits or usr_$last10
      final directDoc = await _firestore.collection('users').doc('usr_$cleanDigits').get();
      if (directDoc.exists && directDoc.data() != null) {
        final d = directDoc.data()!;
        return {
          'userId': directDoc.id,
          'name': d['name'] ?? 'Admin',
          'phone': d['phone'] ?? rawPhone,
          'companyName': d['companyName'] ?? 'Takse Call Enterprise',
          'connectCode': d['connectCode'] ?? '',
          'role': d['role'] ?? 'Super Admin',
        };
      }

      // 2. Query users collection by phone variations
      for (final phoneVar in phoneVariations) {
        final query = await _firestore.collection('users').where('phone', isEqualTo: phoneVar).limit(1).get();
        if (query.docs.isNotEmpty) {
          final d = query.docs.first.data();
          return {
            'userId': query.docs.first.id,
            'name': d['name'] ?? 'Admin',
            'phone': d['phone'] ?? phoneVar,
            'companyName': d['companyName'] ?? 'Takse Call Enterprise',
            'connectCode': d['connectCode'] ?? '',
            'role': d['role'] ?? 'Super Admin',
          };
        }
      }

      // 3. Query devices collection by userPhone variations
      for (final phoneVar in phoneVariations) {
        final query = await _firestore.collection('devices').where('userPhone', isEqualTo: phoneVar).limit(1).get();
        if (query.docs.isNotEmpty) {
          final d = query.docs.first.data();
          final code = d['connectCode'] ?? query.docs.first.id;
          return {
            'userId': d['userId'] ?? 'usr_$last10',
            'name': d['userName'] ?? d['name'] ?? 'Admin',
            'phone': d['userPhone'] ?? phoneVar,
            'companyName': d['companyName'] ?? 'Takse Call Enterprise',
            'connectCode': code,
            'role': d['role'] ?? 'Super Admin',
          };
        }
      }
    } catch (e) {
      debugPrint('Error searching user by phone: $e');
    }
    return null;
  }

  /// Retrieves an existing connect code for the user or creates a new one in Firestore.
  static Future<String> getOrCreateConnectCode({
    required String userId,
    required String name,
    required String phone,
    String? companyName,
  }) async {
    try {
      // 1. Check if user with this phone already exists
      final existing = await findUserByPhone(phone);
      if (existing != null && (existing['connectCode'] as String? ?? '').isNotEmpty) {
        final code = existing['connectCode'] as String;
        debugPrint('Found existing user for phone $phone with connectCode: $code');
        return code;
      }

      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data()?['connectCode'] != null) {
        final existingCode = userDoc.data()!['connectCode'] as String;
        if (existingCode.isNotEmpty) {
          return existingCode;
        }
      }

      // Generate a new unique connect code
      String newCode = generateCode(name);
      
      // Ensure no collision in Firestore
      final existingWithCode = await _firestore
          .collection('devices')
          .doc(newCode)
          .get();
      
      if (existingWithCode.exists) {
        // regenerate once if collision
        newCode = generateCode(name);
      }

      final now = FieldValue.serverTimestamp();

      // Batch write to users and devices
      final batch = _firestore.batch();
      
      final userRef = _firestore.collection('users').doc(userId);
      batch.set(userRef, {
        'userId': userId,
        'name': name.trim(),
        'phone': phone.trim(),
        'companyName': companyName ?? 'Takse Call Enterprise',
        'connectCode': newCode,
        'role': 'Super Admin',
        'createdAt': now,
        'updatedAt': now,
      }, SetOptions(merge: true));

      final deviceRef = _firestore.collection('devices').doc(newCode);
      batch.set(deviceRef, {
        'connectCode': newCode,
        'userId': userId,
        'userName': name.trim(),
        'userPhone': phone.trim(),
        'companyName': companyName ?? 'Takse Call Enterprise',
        'status': 'pending', // 'pending' until mobile app connects, then 'active'
        'deviceModel': null,
        'pairedAt': null,
        'lastSyncAt': null,
        'createdAt': now,
      }, SetOptions(merge: true));

      await batch.commit();
      return newCode;
    } catch (e) {
      debugPrint('Error saving connect code to Firestore: $e');
      // Return a generated code even if offline/Firestore is temporarily inaccessible
      return generateCode(name);
    }
  }

  /// Create a new device code for an employee (from Manage Screen)
  static Future<String> createEmployeeCode({
    required String orgUserId,
    required String employeeName,
    required String employeePhone,
    String role = 'Sales Agent',
  }) async {
    final code = generateCode(employeeName);
    final now = FieldValue.serverTimestamp();

    await _firestore.collection('devices').doc(code).set({
      'connectCode': code,
      'adminUserId': orgUserId,
      'userName': employeeName.trim(),
      'userPhone': employeePhone.trim(),
      'role': role,
      'status': 'pending',
      'deviceModel': null,
      'pairedAt': null,
      'lastSyncAt': null,
      'createdAt': now,
    });

    return code;
  }
}
