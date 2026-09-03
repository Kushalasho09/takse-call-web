import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BrandLogo extends StatelessWidget {
  final bool isCollapsed;
  final double size;

  const BrandLogo({
    super.key,
    this.isCollapsed = false,
    this.size = 38,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom Logo Emblem matching the Callyzer / Takse Call badge
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Circular arc ring
                SizedBox(
                  width: size * 0.72,
                  height: size * 0.72,
                  child: CircularProgressIndicator(
                    value: 0.85,
                    strokeWidth: 2.5,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.outgoing),
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                // Phone / Speech icon inside
                Icon(
                  Icons.phone_in_talk_rounded,
                  size: size * 0.42,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ),
        if (!isCollapsed) ...[
          const SizedBox(width: 10),
          const Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Takse Call',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Call Analytics',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
