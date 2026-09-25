import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import 'nav_dropdown_menu.dart';

class SubSectionNavBar extends StatelessWidget {
  final String title;
  final String description;
  final List<NavSubItem> items;
  final String selectedSubItemId;
  final ValueChanged<String> onSubItemSelected;
  final List<Widget>? actionButtons;

  const SubSectionNavBar({
    super.key,
    required this.title,
    required this.description,
    required this.items,
    required this.selectedSubItemId,
    required this.onSubItemSelected,
    this.actionButtons,
  });

  void _showDropdownMenu(BuildContext context, GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => overlayEntry.remove(),
            ),
          ),
          Positioned(
            left: position.dx,
            top: position.dy + size.height + 6,
            child: NavDropdownMenu(
              title: title,
              items: items,
              selectedSubItemId: selectedSubItemId,
              onSelect: (sub) {
                onSubItemSelected(sub.id);
                overlayEntry.remove();
              },
              onClose: () => overlayEntry.remove(),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final dropdownButtonKey = GlobalKey();
    final currentSubItem = items.firstWhere(
      (item) => item.id == selectedSubItemId,
      orElse: () => items.first,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Top Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                          ),
                          child: Text(
                            currentSubItem.title,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (actionButtons != null) ...[
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: actionButtons!,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Scrollable Sub-tabs Row with dropdown button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                // Dropdown trigger button (matches user screenshots)
                Builder(
                  builder: (ctx) {
                    return Material(
                      key: dropdownButtonKey,
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => _showDropdownMenu(ctx, dropdownButtonKey),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFCBD5E1)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.list_alt_rounded, size: 16, color: AppColors.textPrimary),
                              SizedBox(width: 6),
                              Text(
                                'All Options',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.textSecondary),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 8),
                const VerticalDivider(width: 1, indent: 6, endIndent: 6),
                const SizedBox(width: 8),

                // Horizontal scrollable tab pills
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: items.map((sub) {
                        final isSelected = sub.id == selectedSubItemId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              key: ValueKey('nav_sub_${sub.id}'),
                              borderRadius: BorderRadius.circular(8),
                              onTap: () => onSubItemSelected(sub.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (sub.icon != null) ...[
                                      Icon(
                                        sub.icon,
                                        size: 14,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                    ],
                                    Text(
                                      sub.title,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
