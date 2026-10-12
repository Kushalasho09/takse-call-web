import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/lead_item.dart';
import 'firestore_sync_service.dart';
import 'web_auth_service.dart';

class WebLeadFirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Real-time stream of leads directly from Firebase Firestore.
  /// Shows organization-specific leads AND all fresh/unassigned incoming leads from Webhook/Sheets.
  static Stream<List<LeadItem>> streamLeads({String? filterConnectCode}) {
    final user = WebAuthService.currentUser;
    final code = filterConnectCode ?? user?.connectCode;
    final orgId = user?.uid;
    final cleanCode = code?.replaceAll('-', '');
    final codes = {
      if (code != null && code.isNotEmpty) code,
      if (cleanCode != null && cleanCode.isNotEmpty) cleanCode,
      if (orgId != null && orgId.isNotEmpty) orgId,
    };

    return _firestore
        .collection('leads')
        .snapshots()
        .map((snapshot) {
      final List<LeadItem> items = [];
      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();
        final docCode = data['connectCode']?.toString();
        final docOrgId = data['assignedOrgId']?.toString();
        
        // Strict 3-Tier Hierarchy:
        // An organization only sees leads that have been assigned to its connectCode or orgId by Super Admin.
        final isMatch = codes.isEmpty || 
                        (docCode != null && docCode.isNotEmpty && codes.contains(docCode)) ||
                        (docOrgId != null && docOrgId.isNotEmpty && codes.contains(docOrgId));

        if (isMatch) {
          items.add(LeadItem.fromFirestore(data, doc.id, items.length));
        }
      }
      return items;
    }).handleError((err) {
      debugPrint('Firestore streamLeads error: $err');
      return <LeadItem>[];
    });
  }

  /// Create or update a lead in Firestore stamped with this organization's connect code
  static Future<void> saveLead(LeadItem lead, {String? connectCode, String? userId}) async {
    try {
      final effectiveCode = connectCode ?? lead.connectCode ?? WebAuthService.currentUser?.connectCode;
      final effectiveUserId = userId ?? lead.userId ?? WebAuthService.currentUser?.uid;

      final docRef = _firestore.collection('leads').doc(lead.id);
      final data = lead.toFirestoreMap();

      if (effectiveCode != null && effectiveCode.isNotEmpty) {
        data['connectCode'] = effectiveCode;
      }
      if (effectiveUserId != null && effectiveUserId.isNotEmpty) {
        data['userId'] = effectiveUserId;
      }
      data['updatedAt'] = FieldValue.serverTimestamp();

      await docRef.set(data, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error saving lead to Firestore: $e');
    }
  }

  /// Update lead pipeline status
  static Future<void> updateLeadStatus(String leadId, String newStatus) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error updating lead status in Firestore: $e');
    }
  }

  /// Trash or restore a lead
  static Future<void> setLeadTrash(String leadId, bool isTrashed) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'isTrashed': isTrashed,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error setting lead trash state in Firestore: $e');
    }
  }

  /// Reassign a lead to a telecaller
  static Future<void> reassignLead(String leadId, String assignedTo, String assignedToPhone) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'assignedTo': assignedTo,
        'assignedToPhone': assignedToPhone,
        'assignedDate': DateTime.now().toIso8601String(),
        'assignmentStatus': 'assigned',
        'status': 'Sent',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error reassigning lead in Firestore: $e');
    }
  }

  /// Bulk assign selected leads to a specific employee
  static Future<int> bulkAssignLeads({
    required List<String> leadIds,
    required String assignedTo,
    required String assignedToPhone,
  }) async {
    if (leadIds.isEmpty) return 0;
    int count = 0;

    for (int b = 0; b < leadIds.length; b += 400) {
      final chunk = leadIds.skip(b).take(400).toList();
      final batch = _firestore.batch();

      for (final id in chunk) {
        final docRef = _firestore.collection('leads').doc(id);
        batch.set(docRef, {
          'assignedTo': assignedTo,
          'assignedToPhone': assignedToPhone,
          'assignedDate': DateTime.now().toIso8601String(),
          'assignmentStatus': 'assigned',
          'status': 'Sent',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        count++;
      }
      await batch.commit();
    }
    return count;
  }

  /// Auto-distribute leads across active employees with fair round-robin
  static Future<int> autoDistributeLeads({
    required List<String> leadIds,
    required List<FirestoreDevice> employees,
  }) async {
    if (leadIds.isEmpty || employees.isEmpty) return 0;
    int count = 0;

    for (int b = 0; b < leadIds.length; b += 400) {
      final chunk = leadIds.skip(b).take(400).toList();
      final batch = _firestore.batch();

      for (int i = 0; i < chunk.length; i++) {
        final emp = employees[(b + i) % employees.length];
        final docRef = _firestore.collection('leads').doc(chunk[i]);
        batch.set(docRef, {
          'assignedTo': emp.userName,
          'assignedToPhone': emp.userPhone,
          'assignedDate': DateTime.now().toIso8601String(),
          'assignmentStatus': 'assigned',
          'status': 'Sent',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        count++;
      }
      await batch.commit();
    }
    return count;
  }

  /// Unassign lead back to fresh pool (sets status back to Pending)
  static Future<void> unassignLead(String leadId) async {
    try {
      await _firestore.collection('leads').doc(leadId).update({
        'assignedTo': '',
        'assignedToPhone': '',
        'assignedDate': '',
        'assignmentStatus': 'unassigned',
        'status': 'Pending',
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error unassigning lead in Firestore: $e');
    }
  }

  /// Distribute custom quotas across employees (e.g. Emp 1: 10, Emp 2: 5, Emp 3: 15)
  static Future<int> distributeCustomQuotas({
    required List<String> pendingLeadIds,
    required Map<String, int> employeeQuotas,
    required List<FirestoreDevice> employees,
  }) async {
    if (pendingLeadIds.isEmpty || employeeQuotas.isEmpty || employees.isEmpty) return 0;
    int leadPointer = 0;
    int totalAssigned = 0;

    final List<Map<String, dynamic>> assignments = [];

    for (final entry in employeeQuotas.entries) {
      final phone = entry.key;
      final quota = entry.value;
      if (quota <= 0) continue;

      final emp = employees.firstWhere(
        (e) => e.userPhone == phone,
        orElse: () => employees.first,
      );

      for (int i = 0; i < quota && leadPointer < pendingLeadIds.length; i++) {
        final leadId = pendingLeadIds[leadPointer++];
        assignments.add({
          'leadId': leadId,
          'emp': emp,
        });
      }
    }

    if (assignments.isEmpty) return 0;

    for (int b = 0; b < assignments.length; b += 400) {
      final chunk = assignments.skip(b).take(400).toList();
      final batch = _firestore.batch();

      for (final item in chunk) {
        final String leadId = item['leadId'];
        final FirestoreDevice emp = item['emp'];
        final docRef = _firestore.collection('leads').doc(leadId);

        batch.set(docRef, {
          'assignedTo': emp.userName,
          'assignedToPhone': emp.userPhone,
          'assignedDate': DateTime.now().toIso8601String(),
          'assignmentStatus': 'assigned',
          'status': 'Sent',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        totalAssigned++;
      }
      await batch.commit();
    }
    return totalAssigned;
  }

  /// Bulk unassign multiple leads back to Organization Pending pool ("Lead wapis kheench sakte hain")
  static Future<int> bulkUnassignLeads(List<String> leadIds) async {
    if (leadIds.isEmpty) return 0;
    int count = 0;

    for (int b = 0; b < leadIds.length; b += 400) {
      final chunk = leadIds.skip(b).take(400).toList();
      final batch = _firestore.batch();

      for (final id in chunk) {
        final docRef = _firestore.collection('leads').doc(id);
        batch.set(docRef, {
          'assignedTo': '',
          'assignedToPhone': '',
          'assignedDate': '',
          'assignmentStatus': 'unassigned',
          'status': 'Pending',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        count++;
      }
      await batch.commit();
    }
    return count;
  }

  /// Delete lead permanently
  static Future<void> deleteLead(String leadId) async {
    try {
      await _firestore.collection('leads').doc(leadId).delete();
    } catch (e) {
      debugPrint('Error deleting lead from Firestore: $e');
    }
  }
}
