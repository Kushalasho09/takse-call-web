import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'phone_mockup.dart';

class RegisterEmployeeView extends StatefulWidget {
  final VoidCallback onBack;
  final String connectCode;

  const RegisterEmployeeView({
    super.key,
    required this.onBack,
    this.connectCode = 'ASH-3426-0915',
  });

  @override
  State<RegisterEmployeeView> createState() => _RegisterEmployeeViewState();
}

class _RegisterEmployeeViewState extends State<RegisterEmployeeView> {
  // Step 0 = Overview / Intro video, 1..8 = Steps 1 through 8
  int _currentStep = 0;
  String _selectedLanguage = 'English';

  final List<String> _stepTitles = [
    'Install Callyzer Biz Android App On Employee Phone',
    'Allow App Permissions',
    'Enter Device Connect Code',
    'Select The SIM',
    'Connect The SIM',
    'Phone Number Verification',
    'Allow Callyzer Biz To Overlap',
    'Enable The Auto-Start Permission',
  ];

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFF97316),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showShareWithEmployeesDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.share_rounded, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Share Setup Guide with Employees', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Send your organization connect code and app download instructions to your team members.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),

              // Connect Code Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.vpn_key_rounded, color: Color(0xFFD97706)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Your Organization Device Connect Code', style: TextStyle(fontSize: 11, color: Color(0xFF92400E))),
                        Text(widget.connectCode, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFFB45309), letterSpacing: 1.1)),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFFD97706)),
                      tooltip: 'Copy Code',
                      onPressed: () => _copyToClipboard(widget.connectCode, 'Device connect code copied!'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prepared Message
              const Text('Pre-formatted Message for WhatsApp / Email:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: SelectableText(
                  'Hello team,\nPlease download the Callyzer / Takse Call Biz app from Google Play: https://play.google.com/store/apps/details?id=com.websoptimization.callyzerbiz\n\nWhen prompted, enter our organization connect code: ${widget.connectCode} and choose your official work SIM.',
                  style: const TextStyle(fontSize: 12, height: 1.4, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _copyToClipboard(
                'Hello team,\nPlease download the Callyzer / Takse Call Biz app from Google Play: https://play.google.com/store/apps/details?id=com.websoptimization.callyzerbiz\n\nWhen prompted, enter our organization connect code: ${widget.connectCode} and choose your official work SIM.',
                'Message template copied to clipboard!',
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: const Text('Copy Invitation Message'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Bar
          _buildTopHeader(),
          const Divider(height: 1, color: AppColors.border),

          // Main 2-Column Body
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left Stepper Sidebar
                SizedBox(
                  width: 320,
                  child: _buildLeftStepper(),
                ),

                const VerticalDivider(width: 1, color: AppColors.border),

                // Right Content Area
                Expanded(
                  child: _buildRightStepContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 1. Top Header
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          // Back button
          InkWell(
            onTap: widget.onBack,
            borderRadius: BorderRadius.circular(6),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18, color: Color(0xFFF97316)),
                  SizedBox(width: 6),
                  Text(
                    'Back to Employees',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFF97316),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          const Text(
            'Register a new employee to Callyzer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),

          // Share with Employees Button
          ElevatedButton.icon(
            onPressed: _showShareWithEmployeesDialog,
            icon: const Icon(Icons.share_rounded, size: 16),
            label: const Text('Share with Employees'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Left Stepper Sidebar
  Widget _buildLeftStepper() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Setup Guide Overview Tab
          InkWell(
            onTap: () => setState(() => _currentStep = 0),
            borderRadius: BorderRadius.circular(6),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24, right: 38),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: 16,
                    color: _currentStep == 0 ? const Color(0xFFF97316) : const Color(0xFF64748B),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Setup Guide Overview',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _currentStep == 0 ? FontWeight.bold : FontWeight.w500,
                      color: _currentStep == 0 ? const Color(0xFFF97316) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 8 Numbered Steps with clean continuous timeline
          for (int i = 0; i < _stepTitles.length; i++)
            _buildStepItem(
              stepNumber: i + 1,
              title: _stepTitles[i],
              isFirst: i == 0,
              isLast: i == _stepTitles.length - 1,
            ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required int stepNumber,
    required String title,
    required bool isFirst,
    required bool isLast,
  }) {
    final isActive = _currentStep == stepNumber;

    return InkWell(
      onTap: () => setState(() => _currentStep = stepNumber),
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left: Step title (right-aligned)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 22, right: 14),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Text(
                    title,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                      color: isActive ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ),

            // Right: Continuous 1.5px vertical line with centered circle
            SizedBox(
              width: 32,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  // Continuous Line through the center
                  Positioned(
                    top: isFirst ? 18 : 0,
                    bottom: isLast ? 18 : 0,
                    child: Container(
                      width: 1.5,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),

                  // Circle Badge
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? const Color(0xFF18181B) : Colors.white,
                      border: Border.all(
                        color: isActive ? const Color(0xFF18181B) : const Color(0xFFCBD5E1),
                        width: 1.5,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$stepNumber',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isActive ? Colors.white : const Color(0xFFF97316),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. Right Step Content Area
  Widget _buildRightStepContent() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: _currentStep == 0 ? _buildOverviewStep() : _buildSpecificStep(_currentStep),
    );
  }

  // Step 0: Overview (Image 2)
  Widget _buildOverviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row
        Row(
          children: [
            const Expanded(
              child: Text(
                'Follow these steps on the employee\'s device to register them with Callyzer.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Text('Start', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Subtitle
        const Text(
          'This is a quick guide on how to add an employee’s device to Callyzer. Please follow the instructions step by step for an easy setup.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Language Tabs: English | Hindi
        Row(
          children: [
            _languageTab('English'),
            const SizedBox(width: 16),
            _languageTab('Hindi'),
          ],
        ),
        const SizedBox(height: 16),

        // Video Guide Card
        Container(
          height: 380,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background banner illustration
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'HOW TO',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Register\nEmployees\nIn Callyzer',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32, height: 1.1),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$_selectedLanguage  🔊',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 60),
                          // Phone graphic
                          Container(
                            width: 140,
                            height: 250,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24, width: 3),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFF97316),
                                    ),
                                    child: const Center(
                                      child: Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('Callyzer Biz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // YouTube play overlay
              Center(
                child: Container(
                  width: 68,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF0000),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                  ),
                ),
              ),

              // Bottom YouTube watermark button
              Positioned(
                bottom: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Watch on ', style: TextStyle(color: Colors.white, fontSize: 11)),
                      Icon(Icons.play_circle_fill_rounded, color: Colors.red, size: 14),
                      SizedBox(width: 4),
                      Text('YouTube', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _languageTab(String lang) {
    final isSelected = _selectedLanguage == lang;
    return InkWell(
      onTap: () => setState(() => _selectedLanguage = lang),
      child: Column(
        children: [
          Text(
            lang,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFFF97316) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 2,
            width: 44,
            color: isSelected ? const Color(0xFFF97316) : Colors.transparent,
          ),
        ],
      ),
    );
  }

  // Steps 1 to 8
  Widget _buildSpecificStep(int step) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Navigation row
        Row(
          children: [
            Expanded(
              child: Text(
                'Step $step: ${_getStepHeaderTitle(step)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (step > 1) ...[
              ElevatedButton(
                onPressed: () => setState(() => _currentStep--),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                child: const Text('← Prev', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const SizedBox(width: 8),
            ],
            ElevatedButton(
              onPressed: () {
                if (step < 8) {
                  setState(() => _currentStep++);
                } else {
                  widget.onBack();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Employee Registration Guide Completed!'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: Text(
                step < 8 ? 'Next →' : 'Finish & View Roster ✓',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Step Body
        _buildStepBodyContent(step),
      ],
    );
  }

  String _getStepHeaderTitle(int step) {
    switch (step) {
      case 1:
        return 'Install Callyzer Biz';
      case 2:
        return 'Allow App Permissions';
      case 3:
        return 'Enter Device Connect Code';
      case 4:
        return 'Select the SIM';
      case 5:
        return 'Connect the SIM';
      case 6:
        return 'Phone Number Verification';
      case 7:
        return 'Allow Callyzer Biz overlap';
      case 8:
        return 'Enable the auto start permission';
      default:
        return '';
    }
  }

  Widget _buildStepBodyContent(int step) {
    switch (step) {
      case 1:
        return _buildStep1Install();
      case 2:
        return _buildStep2Permissions();
      case 3:
        return _buildStep3ConnectCode();
      case 4:
        return _buildStep4SelectSim();
      case 5:
        return _buildStep5ConnectSim();
      case 6:
        return _buildStep6VerifyPhone();
      case 7:
        return _buildStep7Overlap();
      case 8:
        return _buildStep8AutoStart();
      default:
        return const SizedBox.shrink();
    }
  }

  // Step 1: Install Callyzer Biz (Image 3)
  Widget _buildStep1Install() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
                  children: [
                    TextSpan(text: 'Download and install the '),
                    TextSpan(
                      text: 'Callyzer Biz',
                      style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                    ),
                    TextSpan(text: ' application from the Playstore.\n\nTo download the application, Click:'),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Google Play Badge
              InkWell(
                onTap: () {
                  _copyToClipboard(
                    'https://play.google.com/store/apps/details?id=com.websoptimization.callyzerbiz',
                    'Google Play Store URL copied!',
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.play_arrow_rounded, color: Color(0xFF00E676), size: 28),
                      SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GET IT ON', style: TextStyle(color: Colors.white70, fontSize: 9, letterSpacing: 0.5)),
                          Text('Google Play', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Help tip card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: Ensure the employee installs "Callyzer Biz" (or Takse Call Biz) on the Android phone used for official business calls.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        // Phone Mockup (Step 1 Splash)
        const PhoneMockup(
          type: PhoneMockupType.splash,
          width: 250,
          height: 480,
        ),
      ],
    );
  }

  // Step 2: Permissions (Image 4 - 3 phones side-by-side)
  Widget _buildStep2Permissions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'After installation, the application will ask for basic permissions. These permissions are mandatory to allow.\nClick “Allow” to give permission.',
          style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
        ),
        const SizedBox(height: 24),

        // 3 Phones Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // Phone 1: Contacts
              PhoneMockup(
                type: PhoneMockupType.permissionContacts,
                width: 230,
                height: 460,
                connectCode: widget.connectCode,
              ),
              const SizedBox(width: 24),

              // Phone 2: Call History
              PhoneMockup(
                type: PhoneMockupType.permissionCallHistory,
                width: 230,
                height: 460,
                connectCode: widget.connectCode,
              ),
              const SizedBox(width: 24),

              // Phone 3: Notifications
              PhoneMockup(
                type: PhoneMockupType.permissionNotifications,
                width: 230,
                height: 460,
                connectCode: widget.connectCode,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Step 3: Enter Connect Code
  Widget _buildStep3ConnectCode() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Callyzer Biz will ask for a Device Connect Code. You can get your device connect code from the organization or company.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 16),

              // Connect Code highlight container
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.key_rounded, color: Color(0xFFD97706)),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('The device connect code is', style: TextStyle(fontSize: 12, color: Color(0xFF92400E))),
                        Text(
                          widget.connectCode,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFFB45309),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _copyToClipboard(widget.connectCode, 'Device code copied to clipboard!'),
                      icon: const Icon(Icons.copy_rounded, size: 14),
                      label: const Text('Copy Code'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              const Text(
                'Enter the Device Connect Code and click “Next”.',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF2563EB), size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All employees of your company use this SAME organization code to link their phones to your central admin dashboard.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.connectCode,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }

  // Step 4: Select SIM
  Widget _buildStep4SelectSim() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select the SIM you want to connect and sync your calling activities with Callyzer Biz.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'For example, if you have two SIM cards — BSNL for personal use and Jio for official calls — you should select (check) Jio and deselect (uncheck) BSNL.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'This way, only your Jio call data will sync with Callyzer, while BSNL calls will not be tracked.',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A), height: 1.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'After selecting the appropriate SIM, click the “Connect” button to proceed to the next screen.',
                style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Color(0xFF059669)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Employee Privacy Guaranteed: Unselected SIMs will remain 100% private and their logs will never leave the employee phone.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.selectSim,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }

  // Step 5: Connect SIM Form
  Widget _buildStep5ConnectSim() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Fill in the required basic details to complete the SIM connection process. Once all details are entered, click on the “Connect” button to proceed.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              SizedBox(height: 20),
              Text(
                'Required Fields on Employee Phone:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              BulletPoint(text: 'Employee Name (e.g. Vishal Patel)'),
              BulletPoint(text: 'Official Phone Number (matching active SIM)'),
              BulletPoint(text: 'Designation / Department (e.g. Sales Executive)'),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.connectSimForm,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }

  // Step 6: Phone Number Verification
  Widget _buildStep6VerifyPhone() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To successfully map the SIM card with call logs, you need to verify your phone number. There are two options to verify. You can choose any one.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 18),

              // Option 1 Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF93C5FD)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Option 1: Verify via call log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF))),
                    SizedBox(height: 4),
                    Text(
                      'Application will show you a call log list, you simply need to select the call log which was made using the phone number you are going to register with callyzer and click “Done”.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E3A8A)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Option 2 Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Option 2: Verify via dummy call', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                    SizedBox(height: 4),
                    Text(
                      'Application will make a 5s dummy call on your registered mobile number to verify. If the call is not auto disconnected in 5s, you can disconnect from your end.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.verifyPhone,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }

  // Step 7: Overlap Permission
  Widget _buildStep7Overlap() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Allow Callyzer biz to overlap other applications on your mobile phone. This feature will help you to comment/add notes after completing each call.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              SizedBox(height: 20),
              BulletPoint(text: 'Enables quick call summary dialog right after hanging up'),
              BulletPoint(text: 'Allows salesmen to tag leads directly while on call'),
              BulletPoint(text: 'Configurable in Android Settings > Display Over Other Apps'),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.allowOverlap,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }

  // Step 8: Auto-Start Permission
  Widget _buildStep8AutoStart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Click “Allow” to enable the auto start option. By allowing auto start, the application will run in background and keep syncing your data.',
                style: TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.5),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.check_circle_rounded, color: Color(0xFF10B981)),
                        SizedBox(width: 8),
                        Text('Employee Registration Completed!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'As soon as the employee completes this 8th step, their phone name, model, SIM info, and real-time call records will immediately appear in your Manage Employees table!',
                      style: TextStyle(fontSize: 12, color: Color(0xFF047857), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 40),

        PhoneMockup(
          type: PhoneMockupType.allowAutoStart,
          width: 250,
          height: 480,
          connectCode: widget.connectCode,
        ),
      ],
    );
  }
}

class BulletPoint extends StatelessWidget {
  final String text;

  const BulletPoint({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFFF97316),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
          ),
        ],
      ),
    );
  }
}
