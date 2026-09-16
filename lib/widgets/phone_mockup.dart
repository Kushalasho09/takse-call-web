import 'package:flutter/material.dart';

enum PhoneMockupType {
  splash,
  permissionContacts,
  permissionCallHistory,
  permissionNotifications,
  connectCode,
  selectSim,
  connectSimForm,
  verifyPhone,
  allowOverlap,
  allowAutoStart,
}

class PhoneMockup extends StatelessWidget {
  final PhoneMockupType type;
  final double width;
  final double height;
  final String? connectCode;

  const PhoneMockup({
    super.key,
    required this.type,
    this.width = 230,
    this.height = 460,
    this.connectCode = 'ASH-3426-0915',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF3F3F46), width: 3.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              // Top Status Bar & Notch
              _buildStatusBar(),

              // Screen Content
              Expanded(
                child: _buildScreenBody(context),
              ),

              // Bottom Android Navigation Pill
              _buildBottomBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar() {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '2:37 PM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          Container(
            width: 48,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F172A),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi, size: 10, color: Color(0xFF334155)),
              SizedBox(width: 4),
              Icon(Icons.signal_cellular_4_bar, size: 10, color: Color(0xFF334155)),
              SizedBox(width: 4),
              Icon(Icons.battery_full, size: 11, color: Color(0xFF334155)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 18,
      alignment: Alignment.center,
      child: Container(
        width: 68,
        height: 3.5,
        decoration: BoxDecoration(
          color: const Color(0xFF94A3B8),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildScreenBody(BuildContext context) {
    switch (type) {
      case PhoneMockupType.splash:
        return _buildSplashScreen();
      case PhoneMockupType.permissionContacts:
        return _buildPermissionScreen(
          icon: Icons.person_outline_rounded,
          title: 'Access to Your Contacts',
          dialogTitle: 'Allow Takse Call Biz to access your contacts?',
          badgeColor: const Color(0xFF3B82F6),
        );
      case PhoneMockupType.permissionCallHistory:
        return _buildPermissionScreen(
          icon: Icons.phone_callback_rounded,
          title: 'Allow to access your call history',
          dialogTitle: 'Allow Takse Call Biz to make and manage phone calls?',
          badgeColor: const Color(0xFF10B981),
        );
      case PhoneMockupType.permissionNotifications:
        return _buildPermissionScreen(
          icon: Icons.notifications_none_rounded,
          title: 'Get Notified!',
          dialogTitle: 'Allow Takse Call Biz to send you notifications?',
          badgeColor: const Color(0xFFF59E0B),
        );
      case PhoneMockupType.connectCode:
        return _buildConnectCodeScreen();
      case PhoneMockupType.selectSim:
        return _buildSelectSimScreen();
      case PhoneMockupType.connectSimForm:
        return _buildConnectSimFormScreen();
      case PhoneMockupType.verifyPhone:
        return _buildVerifyPhoneScreen();
      case PhoneMockupType.allowOverlap:
        return _buildAllowOverlapScreen();
      case PhoneMockupType.allowAutoStart:
        return _buildAllowAutoStartScreen();
    }
  }

  // 1. Splash Screen
  Widget _buildSplashScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(20),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Circular Logo Badge
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Tri-color arc ring
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      value: 0.8,
                      strokeWidth: 4,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF97316)),
                      backgroundColor: const Color(0xFF22C55E),
                    ),
                  ),
                  const Text(
                    'B',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Takse Call Biz',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Business Calling Analytics',
              style: TextStyle(
                fontSize: 10,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Permission Screen
  Widget _buildPermissionScreen({
    required IconData icon,
    required String title,
    required String dialogTitle,
    required Color badgeColor,
  }) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        children: [
          const SizedBox(height: 10),
          // Heading inside phone
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const Spacer(),

          // Center illustration avatar
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(icon, size: 36, color: badgeColor),
            ),
          ),

          const Spacer(),

          // System Permission Dialog Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: badgeColor),
                const SizedBox(height: 8),
                Text(
                  dialogTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Allow',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Don\'t allow',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  // 3. Connect Code Screen
  Widget _buildConnectCodeScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 14),
          const Center(
            child: Text(
              'Enter Device Connect Code',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Ask your administrator for your organization\'s unique device connect code.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 20),

          // Code display block
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.vpn_key_rounded, size: 15, color: Color(0xFFD97706)),
                const SizedBox(width: 6),
                Text(
                  connectCode ?? 'ASH-3426-0915',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF92400E),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Next Button
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Next →',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 4. Select SIM Screen
  Widget _buildSelectSimScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Select Official SIM',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select which SIM card call logs to sync.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 18),

          // SIM 1 (Personal - unchecked)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_box_outline_blank_rounded, size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SIM 1: BSNL (Personal)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600)),
                      Text('Exclude personal calls', style: TextStyle(fontSize: 8.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // SIM 2 (Official - checked)
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFF59E0B)),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_box_rounded, size: 16, color: Color(0xFFD97706)),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SIM 2: Jio 5G (Official)', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF92400E))),
                      Text('Sync calls to dashboard', style: TextStyle(fontSize: 8.5, color: Color(0xFFB45309))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Connect SIM',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 5. Connect SIM Form Screen
  Widget _buildConnectSimFormScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Employee Details',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 16),

          _miniField('Employee Name', 'Vishal Patel'),
          const SizedBox(height: 10),
          _miniField('Official Mobile Number', '+91 88007 19093'),
          const SizedBox(height: 10),
          _miniField('Designation', 'Sales Lead'),

          const Spacer(),

          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Submit & Connect',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _miniField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Text(value, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
        ),
      ],
    );
  }

  // 6. Verify Phone Screen
  Widget _buildVerifyPhoneScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Phone Verification',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose verification method for SIM mapping',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 16),

          // Option 1
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: const Row(
              children: [
                Icon(Icons.radio_button_checked_rounded, size: 16, color: Color(0xFF2563EB)),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Option 1: Verify via Call Log', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8))),
                      Text('Select recent call from list', style: TextStyle(fontSize: 8.5, color: Color(0xFF3B82F6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Option 2
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.radio_button_off_rounded, size: 16, color: Colors.grey),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Option 2: 5s Dummy Call', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      Text('Auto-verification missed call', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Verify & Proceed',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 7. Overlap Screen
  Widget _buildAllowOverlapScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.arrow_back, size: 16, color: Color(0xFF334155)),
              SizedBox(width: 8),
              Text(
                'Display over other apps',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF59E0B),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('B', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Takse Call Biz', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      Text('Allowed', style: TextStyle(fontSize: 8.5, color: Color(0xFF10B981), fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeTrackColor: const Color(0xFFF59E0B),
                  activeThumbColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Floating Call note preview card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.call_end_rounded, color: Colors.redAccent, size: 14),
                    SizedBox(width: 6),
                    Text('Call Ended • 03:24', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w600)),
                  ],
                ),
                SizedBox(height: 6),
                Text('Add quick note or tag lead right from screen overlay!', style: TextStyle(color: Colors.white70, fontSize: 8.5)),
              ],
            ),
          ),

          const Spacer(),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Next →',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // 8. Auto-Start Screen
  Widget _buildAllowAutoStartScreen() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.arrow_back, size: 16, color: Color(0xFF334155)),
              SizedBox(width: 8),
              Text(
                'Auto-start Permission',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on_rounded, color: Color(0xFFF59E0B), size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Takse Call Biz Auto-start', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      Text('Keep syncing in background', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                Switch(
                  value: true,
                  onChanged: (v) {},
                  activeTrackColor: const Color(0xFF10B981),
                  activeThumbColor: Colors.white,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Success completion illustration
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 32),
                SizedBox(height: 6),
                Text(
                  'Device Ready & Connected!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF065F46)),
                ),
                SizedBox(height: 4),
                Text(
                  'Employee call logs will now sync in real-time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 9, color: Color(0xFF047857)),
                ),
              ],
            ),
          ),

          const Spacer(),
          Container(
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF10B981),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Complete Setup ✓',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
