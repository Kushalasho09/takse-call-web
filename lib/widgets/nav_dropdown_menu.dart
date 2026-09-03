import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';

class NavDropdownMenu extends StatelessWidget {
  final String title;
  final List<NavSubItem> items;
  final String? selectedSubItemId;
  final ValueChanged<NavSubItem> onSelect;
  final VoidCallback? onClose;

  const NavDropdownMenu({
    super.key,
    required this.title,
    required this.items,
    this.selectedSubItemId,
    required this.onSelect,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 240,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 18,
              spreadRadius: 2,
              offset: Offset(4, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _buildMenuItem(items[i]),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFE2E8F0),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(NavSubItem item) {
    final isSelected = item.id == selectedSubItemId;

    return NavDropdownItemWidget(
      item: item,
      isSelected: isSelected,
      onTap: () {
        onSelect(item);
        if (onClose != null) {
          onClose!();
        }
      },
    );
  }
}

class NavDropdownItemWidget extends StatefulWidget {
  final NavSubItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const NavDropdownItemWidget({
    super.key,
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<NavDropdownItemWidget> createState() => _NavDropdownItemWidgetState();
}

class _NavDropdownItemWidgetState extends State<NavDropdownItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: _isHovered
              ? const Color(0xFFF1F5F9)
              : (widget.isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.white),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 17,
                  color: widget.isSelected
                      ? AppColors.primary
                      : (_isHovered ? AppColors.textPrimary : const Color(0xFF64748B)),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  widget.item.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: widget.isSelected ? AppColors.primary : const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              if (widget.isSelected)
                const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
