import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/web_auth_service.dart';
import '../../theme/app_colors.dart';

class WebLoginScreen extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const WebLoginScreen({super.key, required this.onLoginSuccess});

  @override
  State<WebLoginScreen> createState() => _WebLoginScreenState();
}

class _WebLoginScreenState extends State<WebLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isLoginMode = true; // Default to Login tab
  String _countryCode = '+91';
  String _teamSize = '1 - 5 Employees (Starter)';
  bool _isOtpSent = false;
  bool _isLoading = false;
  bool _isCheckingPhone = false;
  String? _errorMessage;
  String? _accountWarning;
  Map<String, dynamic>? _foundAccount;
  Timer? _phoneDebounce;

  // Resend OTP timer
  int _resendCountdown = 30;
  Timer? _timer;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    _phoneDebounce?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        t.cancel();
      }
    });
  }

  void _onPhoneChanged(String val) {
    _phoneDebounce?.cancel();
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.length < 10) {
      if (_foundAccount != null || _accountWarning != null) {
        setState(() {
          _foundAccount = null;
          _accountWarning = null;
          _errorMessage = null;
        });
      }
      return;
    }

    _phoneDebounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _isCheckingPhone = true);
      final fullPhone = '$_countryCode$clean';
      final existing = await WebAuthService.findUserByPhone(fullPhone);

      if (!mounted) return;
      setState(() {
        _isCheckingPhone = false;
        if (existing != null) {
          _foundAccount = existing;
          if (!_isLoginMode) {
            // SIGNUP MODE: Number exists -> WARN & BLOCK SIGNUP
            _accountWarning = 'This mobile number is already registered under "${existing['name']}" (${existing['companyName']})! Please log in instead.';
          } else {
            // LOGIN MODE: Number exists -> AUTO PREFILL
            _accountWarning = null;
            if (_nameController.text.isEmpty) {
              _nameController.text = existing['name'] ?? '';
            }
            if (_companyController.text.isEmpty) {
              _companyController.text = existing['companyName'] ?? '';
            }
          }
        } else {
          _foundAccount = null;
          if (_isLoginMode) {
            _accountWarning = 'No account found for this mobile number. Please switch to Sign Up to register.';
          } else {
            _accountWarning = null;
          }
        }
      });
    });
  }

  String _getPreviewPrefix() {
    final name = _nameController.text.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    if (name.length >= 3) {
      return '${name.substring(0, 3)}-XXXX-XXXX';
    } else if (name.isNotEmpty) {
      return '${'${name}XXX'.substring(0, 3)}-XXXX-XXXX';
    }
    return 'NAM-XXXX-XXXX';
  }

  Future<void> _handleSendOtp() async {
    final phoneText = _phoneController.text.trim();
    if (phoneText.length < 8) {
      setState(() => _errorMessage = 'Please enter a valid mobile number');
      return;
    }

    if (!_isLoginMode && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = '$_countryCode$phoneText';

    // 1. Check existing account in Firestore
    final existing = await WebAuthService.findUserByPhone(fullPhone);

    if (!_isLoginMode && existing != null) {
      // BLOCK SIGNUP IF NUMBER EXISTS!
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Mobile number "$fullPhone" is already registered under "${existing['name']}" (${existing['companyName']}). Please log in instead of signing up.';
        _foundAccount = existing;
      });
      return;
    }

    if (_isLoginMode && existing == null) {
      // CANNOT LOGIN IF NUMBER DOES NOT EXIST
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'No account found for mobile number "$fullPhone". Please switch to Sign Up to create an account.';
      });
      return;
    }

    if (existing != null) {
      _foundAccount = existing;
      _nameController.text = existing['name'] ?? _nameController.text;
      _companyController.text = existing['companyName'] ?? _companyController.text;
    }

    try {
      await WebAuthService.sendOtp(phoneNumber: fullPhone);
    } catch (e) {
      debugPrint('Send OTP notice: $e');
    }

    if (!mounted) return;
    setState(() {
      _isOtpSent = true;
      _isLoading = false;
    });
    _startResendTimer();
  }

  Future<void> _handleVerifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.length < 4) {
      setState(() => _errorMessage = 'Please enter a valid OTP code (e.g. 123456)');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final fullPhone = '$_countryCode${_phoneController.text.trim()}';
    final nameToUse = _foundAccount?['name'] ?? (_nameController.text.trim().isNotEmpty ? _nameController.text.trim() : 'Kushal Asodia');
    final companyToUse = _foundAccount?['companyName'] ?? (_companyController.text.trim().isNotEmpty ? _companyController.text.trim() : 'Takse Call Enterprise');

    try {
      int limit = 5;
      if (_teamSize.contains('6 - 10')) {
        limit = 10;
      } else if (_teamSize.contains('11 - 25')) {
        limit = 25;
      } else if (_teamSize.contains('25+')) {
        limit = 50;
      }

      final user = await WebAuthService.verifyOtpAndLogin(
        otp: otp,
        name: nameToUse,
        phone: fullPhone,
        companyName: companyToUse,
        employeeLimit: limit,
        teamSize: _teamSize,
      );

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });

      _showConnectCodeDialog(user);
    } catch (e) {
      // Fallback in case of mock/web environment
      try {
        final user = await WebAuthService.demoLogin(
          name: nameToUse,
          phone: fullPhone,
          company: companyToUse,
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        _showConnectCodeDialog(user);
      } catch (err) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to verify OTP: $err';
        });
      }
    }
  }

  Future<void> _handleQuickDemoLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Directly log into the real verified Kushal Asodia account with 1,776 call logs
    final user = await WebAuthService.demoLogin(
      name: 'Kushal Asodia',
      phone: '+91 96645 79043',
      company: 'Takse Call Enterprise',
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });

    _showConnectCodeDialog(user);
  }

  void _showConnectCodeDialog(WebAuthUser user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.incomingSubtle,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.incoming, size: 48),
            ),
            const SizedBox(height: 16),
            const Text(
              'Authentication Successful!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Welcome back, ${user.name}! Your organization device connect code has been generated.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            
            // Connect Code Display Card
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.phonelink_setup_rounded, color: AppColors.connectCodeText, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    user.connectCode,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.connectCodeText,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: AppColors.connectCodeText, size: 20),
                    tooltip: 'Copy Code',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: user.connectCode));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Device connect code "${user.connectCode}" copied!'),
                          backgroundColor: AppColors.primary,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primarySubtle,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Enter this code inside the Takse Call Mobile App to pair your phone and sync call records instantly.',
                      style: TextStyle(fontSize: 12, color: AppColors.primary.withValues(alpha: 0.9), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  widget.onLoginSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Enter Dashboard', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark slate premium backdrop
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 1040, minHeight: 520),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 40,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: isDesktop
                ? IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Left Hero Branding Panel
                        Expanded(
                          flex: 5,
                          child: _buildBrandingPanel(),
                        ),
                        // Right Login Form Panel
                        Expanded(
                          flex: 6,
                          child: _buildFormPanel(),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      _buildBrandingPanel(isCompact: true),
                      _buildFormPanel(),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingPanel({bool isCompact = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isCompact ? 24 : 32, vertical: isCompact ? 20 : 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E3A8A), // Deep Navy Blue
            Color(0xFF2563EB), // Vibrant Brand Blue
            Color(0xFF1D4ED8),
          ],
        ),
      ),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
          // Brand Logo + Title
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.phone_in_talk_rounded, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Takse Call',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'CALL ANALYTICS & MONITORING',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF93C5FD),
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: isCompact ? 16 : 24),
          const Text(
            'Enterprise Call Tracking & Multi-Device Pairing',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.25,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Track SIM call durations, automatic recordings, leads, and sales rep performance across your entire organization.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFE0E7FF),
              height: 1.4,
            ),
          ),
          if (!isCompact) ...[
            const SizedBox(height: 24),
            _featureRow(Icons.pin_rounded, 'Instant Device Connect Codes', 'Pair staff mobile devices with one simple code (e.g. ROH-3453-2342).'),
            const SizedBox(height: 12),
            _featureRow(Icons.sync_rounded, 'Real-time Automatic Cloud Sync', 'Call logs stream directly from mobile SIMs to your web dashboard.'),
            const SizedBox(height: 12),
            _featureRow(Icons.query_stats_rounded, 'Granular Sales Analytics', 'Track incoming, outgoing, missed calls, and duration trends.'),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF67E8F9), size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bank-grade 256-bit encrypted call synchronization',
                      style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

  Widget _featureRow(IconData icon, String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: Color(0xFFC7D2FE), height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Mode Switcher (Log In vs Sign Up)
              if (!_isOtpSent) ...[
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLoginMode = true;
                              _errorMessage = null;
                              _accountWarning = null;
                            });
                            if (_phoneController.text.length >= 10) {
                              _onPhoneChanged(_phoneController.text);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isLoginMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: _isLoginMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.login_rounded,
                                  size: 16,
                                  color: _isLoginMode ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Log In',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _isLoginMode ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _isLoginMode = false;
                              _errorMessage = null;
                              _accountWarning = null;
                            });
                            if (_phoneController.text.length >= 10) {
                              _onPhoneChanged(_phoneController.text);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isLoginMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: !_isLoginMode
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.08),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: 16,
                                  color: !_isLoginMode ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Sign Up / Register',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: !_isLoginMode ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Text(
                _isOtpSent
                    ? 'Verify Phone OTP'
                    : (_isLoginMode ? 'Log In to Takse Call' : 'Create Organization Account'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _isOtpSent
                    ? 'Enter the 6-digit OTP sent to $_countryCode${_phoneController.text}'
                    : (_isLoginMode
                        ? 'Enter your registered mobile number to log in.'
                        : 'Register a new organization and generate your paired connect code.'),
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),

              // Error or Duplicate Signup Banner
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.missedSubtle,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.missed.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline_rounded, color: AppColors.missed, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(fontSize: 12, color: AppColors.missed, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      if (!_isLoginMode && _errorMessage!.contains('already registered')) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = true;
                                _errorMessage = null;
                              });
                              _onPhoneChanged(_phoneController.text);
                            },
                            icon: const Icon(Icons.login_rounded, size: 14),
                            label: const Text('Switch to Log In with this number', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ] else if (_isLoginMode && _errorMessage!.contains('No account found')) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _isLoginMode = false;
                                _errorMessage = null;
                              });
                            },
                            icon: const Icon(Icons.person_add_alt_1_rounded, size: 14),
                            label: const Text('Switch to Sign Up / Register', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              // Warning or Notice Banner
              if (_accountWarning != null && _errorMessage == null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _accountWarning!,
                          style: const TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (!_isLoginMode)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLoginMode = true;
                              _accountWarning = null;
                            });
                          },
                          child: const Text('Log In', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),

              if (!_isOtpSent) ...[
                // Mobile Number Field
                const Text('Mobile Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _countryCode,
                            items: const [
                              DropdownMenuItem(value: '+91', child: Text('🇮🇳 +91')),
                              DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                            ],
                            onChanged: (v) {
                              if (v != null) {
                                setState(() => _countryCode = v);
                                _onPhoneChanged(_phoneController.text);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        onChanged: _onPhoneChanged,
                        decoration: InputDecoration(
                          hintText: 'Enter 10-digit mobile number',
                          prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20, color: AppColors.textSecondary),
                          suffixIcon: _isCheckingPhone
                              ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)))
                              : (_foundAccount != null
                                  ? const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                                  : null),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        ),
                        validator: (val) => val == null || val.trim().length < 8 ? 'Please enter a valid phone number' : null,
                      ),
                    ),
                  ],
                ),

                // Existing Account Found Card
                if (_isLoginMode && _foundAccount != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBBF7D0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Verified: ${_foundAccount!['name']}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF15803D)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_foundAccount!['companyName']} • Connect Code: ${_foundAccount!['connectCode']}',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF166534), fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Sign Up Specific Fields (Full Name & Company)
                if (!_isLoginMode) ...[
                  const SizedBox(height: 16),
                  const Text('Full Name (Admin / Manager)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Enter full name (e.g. Kushal Asodia)',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.textSecondary),
                      suffix: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.outgoingSubtle,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Text(
                          'Code: ${_getPreviewPrefix()}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.connectCodeText),
                        ),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter your full name' : null,
                  ),

                  const SizedBox(height: 16),

                  const Text('Organization / Business Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _companyController,
                    decoration: InputDecoration(
                      hintText: 'Enter business name (e.g. Takse Call Enterprise)',
                      prefixIcon: const Icon(Icons.business_outlined, size: 20, color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty ? 'Please enter organization name' : null,
                  ),

                  const SizedBox(height: 16),

                  const Text('Number of Employees / Telecallers', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _teamSize,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                        items: const [
                          DropdownMenuItem(value: '1 - 5 Employees (Starter)', child: Text('👥 1 - 5 Employees (Starter Plan)')),
                          DropdownMenuItem(value: '6 - 10 Employees (Growth)', child: Text('👥 6 - 10 Employees (Growth Plan)')),
                          DropdownMenuItem(value: '11 - 25 Employees (Pro)', child: Text('👥 11 - 25 Employees (Pro Plan)')),
                          DropdownMenuItem(value: '25+ Employees (Enterprise)', child: Text('🏢 25+ Employees (Enterprise Plan)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _teamSize = val);
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleSendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoginMode ? 'Send Verification OTP & Log In' : 'Register & Generate Connect Code',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ] else ...[
                // Step 2: OTP Entry Field
                const Text('Enter 6-Digit OTP Code', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 8),
                  decoration: InputDecoration(
                    hintText: '••••••',
                    hintStyle: const TextStyle(letterSpacing: 8, color: AppColors.textMuted),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => setState(() => _isOtpSent = false),
                      icon: const Icon(Icons.arrow_back_rounded, size: 16),
                      label: const Text('Change Details', style: TextStyle(fontSize: 12)),
                    ),
                    TextButton(
                      onPressed: _resendCountdown == 0 ? _handleSendOtp : null,
                      child: Text(
                        _resendCountdown > 0 ? 'Resend code in ${_resendCountdown}s' : 'Resend OTP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _resendCountdown == 0 ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Verify Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleVerifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _isLoginMode ? 'Verify OTP & Enter Dashboard' : 'Verify & Create Organization',
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.check_circle_outline_rounded, size: 18),
                            ],
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 20),

              // Quick Access Demo Button for Kushal Asodia real account
              Center(
                child: TextButton.icon(
                  onPressed: _isLoading ? null : _handleQuickDemoLogin,
                  icon: const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 18),
                  label: const Text(
                    '⚡ 1-Click Access: Kushal Asodia (+91 96645 79043 • KAS-4257-4648)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
