import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class StatCell extends StatefulWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const StatCell({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  State<StatCell> createState() => _StatCellState();
}

class _StatCellState extends State<StatCell> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = widget.color ?? AppColors.textPrimary;
    final isCustomColor = widget.color != null;

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.color != null
                    ? widget.color!.withValues(alpha: 0.05)
                    : AppColors.scaffoldBackground)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Value (Big Number or Duration string)
              Text(
                widget.value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isCustomColor ? effectiveColor : AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              // Icon + Label
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 14,
                    color: isCustomColor ? effectiveColor : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isCustomColor ? FontWeight.w600 : FontWeight.w500,
                        color: isCustomColor ? effectiveColor : AppColors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
