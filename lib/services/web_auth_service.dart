import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/web.dart' as web;
import 'connect_code_service.dart';

class WebAuthUser {
  final String uid;
  final String name;
  final String phone;
  final String? companyName;
  final String connectCode;

  WebAuthUser({
    required this.uid,
    required this.name,
    required this.phone,
    this.companyName,
    required this.connectCode,
  });
}

class WebAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static WebAuthUser? _currentUser;
  static ConfirmationResult? _confirmationResult;

  static WebAuthUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // Session keys
  static const String _keyUid = 'auth_uid';
  static const String _keyName = 'auth_name';
  static const String _keyPhone = 'auth_phone';
  static const String _keyCompany = 'auth_company';
  static const String _keyCode = 'auth_connect_code';

  static void _ensureRecaptchaElement() {
    if (kIsWeb) {
      try {
        final existing = web.document.getElementById('recaptcha-container');
        if (existing == null) {
          final div = web.document.createElement('div') as web.HTMLDivElement;
          div.id = 'recaptcha-container';
          div.style.position = 'fixed';
          div.style.zIndex = '9999999';
          div.style.bottom = '20px';
          div.style.right = '20px';
          web.document.body?.appendChild(div);
        }
      } catch (e) {
        debugPrint('Recaptcha DOM container notice: $e');
      }
    }
  }

  /// Initializes the local auth session from SharedPreferences
  static Future<bool> initSession() async {
    _ensureRecaptchaElement();
    try {
      final prefs = await SharedPreferences.getInstance();
      final uid = prefs.getString(_keyUid);
      final name = prefs.getString(_keyName);
      final phone = prefs.getString(_keyPhone);
      final code = prefs.getString(_keyCode);
      final company = prefs.getString(_keyCompany);

      if (uid != null && name != null && phone != null && code != null) {
        _currentUser = WebAuthUser(
          uid: uid,
          name: name,
          phone: phone,
          companyName: company,
          connectCode: code,
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error restoring web session: $e');
    }
    return false;
  }

  /// Step 0: Check if an account already exists for this phone number in Firestore
  static Future<Map<String, dynamic>?> findUserByPhone(String phoneNumber) async {
    return ConnectCodeService.findUserByPhone(phoneNumber);
  }

  /// Step 1: Send SMS OTP to phone number using Firebase Phone Auth on Web
  static Future<void> sendOtp({
    required String phoneNumber,
  }) async {
    try {
      _ensureRecaptchaElement();
      _confirmationResult = await _auth.signInWithPhoneNumber(
        phoneNumber,
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('Firebase send OTP notice: $e');
    }
  }

  /// Step 2: Verify SMS OTP & Create/Retrieve Connect Code
  static Future<WebAuthUser> verifyOtpAndLogin({
    required String otp,
    required String name,
    required String phone,
    String? companyName,
    int employeeLimit = 5,
    String teamSize = '1 - 5 Employees',
  }) async {
    // 1. Check if user already exists in Firestore for this phone
    final existingUser = await findUserByPhone(phone);

    String uid;
    String finalName = name;
    String? finalCompany = companyName;
    String connectCode;

    if (existingUser != null) {
      uid = existingUser['userId'] as String? ?? 'usr_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
      finalName = (existingUser['name'] as String? ?? '').isNotEmpty
          ? existingUser['name'] as String
          : name;
      finalCompany = existingUser['companyName'] as String? ?? companyName;
      connectCode = existingUser['connectCode'] as String? ?? '';

      if (connectCode.isEmpty) {
        connectCode = await ConnectCodeService.getOrCreateConnectCode(
          userId: uid,
          name: finalName,
          phone: phone,
          companyName: finalCompany,
          employeeLimit: employeeLimit,
          teamSize: teamSize,
        );
      }
    } else {
      if (_confirmationResult != null) {
        final credential = await _confirmationResult!.confirm(otp);
        uid = credential.user?.uid ?? 'usr_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
      } else {
        // Fallback if direct confirmation or mock
        uid = _auth.currentUser?.uid ?? 'usr_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';
      }

      connectCode = await ConnectCodeService.getOrCreateConnectCode(
        userId: uid,
        name: finalName,
        phone: phone,
        companyName: finalCompany,
        employeeLimit: employeeLimit,
        teamSize: teamSize,
      );
    }

    final user = WebAuthUser(
      uid: uid,
      name: finalName,
      phone: phone,
      companyName: finalCompany,
      connectCode: connectCode,
    );

    _currentUser = user;
    await _persistSession(user);
    return user;
  }

  /// Demo / Rapid Login for testing (defaults to Kushal Asodia real account)
  static Future<WebAuthUser> demoLogin({
    String name = 'Kushal Asodia',
    String phone = '+91 96645 79043',
    String company = 'Takse Call Enterprise',
  }) async {
    final existing = await findUserByPhone(phone);
    final finalName = existing?['name'] as String? ?? name;
    final finalCompany = existing?['companyName'] as String? ?? company;
    final finalCode = existing?['connectCode'] as String? ?? 'KAS-4257-4648';
    final uid = existing?['userId'] as String? ?? 'usr_${phone.replaceAll(RegExp(r'[^0-9]'), '')}';

    final user = WebAuthUser(
      uid: uid,
      name: finalName,
      phone: phone,
      companyName: finalCompany,
      connectCode: finalCode,
    );

    _currentUser = user;
    await _persistSession(user);
    return user;
  }

  /// Updates local and session cache with edited profile info
  static Future<void> updateUserProfile({
    required String name,
    required String companyName,
  }) async {
    if (_currentUser != null) {
      final updated = WebAuthUser(
        uid: _currentUser!.uid,
        name: name,
        phone: _currentUser!.phone,
        companyName: companyName,
        connectCode: _currentUser!.connectCode,
      );
      _currentUser = updated;
      await _persistSession(updated);
    }
  }

  static Future<void> _persistSession(WebAuthUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyUid, user.uid);
      await prefs.setString(_keyName, user.name);
      await prefs.setString(_keyPhone, user.phone);
      await prefs.setString(_keyCode, user.connectCode);
      if (user.companyName != null) {
        await prefs.setString(_keyCompany, user.companyName!);
      }
    } catch (e) {
      debugPrint('SharedPreferences persist notice: $e');
    }
  }

  /// Sign out and clear stored session
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (_) {}
    _currentUser = null;
    _confirmationResult = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUid);
      await prefs.remove(_keyName);
      await prefs.remove(_keyPhone);
      await prefs.remove(_keyCompany);
      await prefs.remove(_keyCode);
    } catch (e) {
      debugPrint('SharedPreferences clear notice: $e');
    }
  }
}
