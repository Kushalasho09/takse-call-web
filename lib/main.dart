import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/web_login_screen.dart';
import 'screens/main_shell.dart';
import 'services/web_auth_service.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  await WebAuthService.initSession();

  runApp(const TakseCallWebApp());
}

class TakseCallWebApp extends StatefulWidget {
  const TakseCallWebApp({super.key});

  @override
  State<TakseCallWebApp> createState() => _TakseCallWebAppState();
}

class _TakseCallWebAppState extends State<TakseCallWebApp> {
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _isAuthenticated = WebAuthService.isLoggedIn;
  }

  void _handleLoginSuccess() {
    setState(() {
      _isAuthenticated = true;
    });
  }

  void _handleLogout() {
    setState(() {
      _isAuthenticated = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Takse Call - Call Analytics Web Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isAuthenticated
          ? MainShell(onLogout: _handleLogout)
          : WebLoginScreen(onLoginSuccess: _handleLoginSuccess),
    );
  }
}

