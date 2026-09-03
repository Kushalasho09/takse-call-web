import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import 'sync_data_button.dart';

class TopHeaderBar extends StatelessWidget {
  final String userName;
  final String deviceCode;
  final VoidCallback? onMenuToggle;
  final VoidCallback? onLogout;

  const TopHeaderBar({
    super.key,
    this.userName = 'Kushal Asodia',
    this.deviceCode = 'KUS-3926-0820',
    this.onMenuToggle,
    this.onLogout,
  });

  void _copyDeviceCode(BuildContext context) {
    Clipboard.setData(ClipboardData(text: deviceCode));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Device connect code "$deviceCode" copied to clipboard!'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: AppColors.topBarBackground,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          if (onMenuToggle != null) ...[
            IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary),
              onPressed: onMenuToggle,
              tooltip: 'Toggle Navigation',
            ),
            const SizedBox(width: 8),
          ],

          // User Name
          Text(
            userName,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),

          const SizedBox(width: 16),

          // Right aligned actions
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              physics: const BouncingScrollPhysics(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Center/Right Connect Code Banner
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => _copyDeviceCode(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Your device connect code is ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              deviceCode,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.connectCodeText,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.copy_rounded, size: 13, color: AppColors.connectCodeText),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Real-time Sync Data Button
                  SyncDataButton(connectCode: deviceCode),

                  const SizedBox(width: 14),

                  // Logout Button
                  TextButton.icon(
                    onPressed: onLogout,
                    icon: const Icon(Icons.logout_rounded, size: 15, color: AppColors.connectCodeText),
                    label: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
