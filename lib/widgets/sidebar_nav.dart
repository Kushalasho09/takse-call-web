import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import 'brand_logo.dart';
import 'nav_dropdown_menu.dart';

class SidebarNav extends StatefulWidget {
  final NavSection selectedSection;
  final String? selectedSubItemId;
  final ValueChanged<NavSection> onSectionSelected;
  final void Function(NavSection section, String subItemId) onSubItemSelected;
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;

  const SidebarNav({
    super.key,
    required this.selectedSection,
    this.selectedSubItemId,
    required this.onSectionSelected,
    required this.onSubItemSelected,
    required this.isCollapsed,
    required this.onToggleCollapse,
  });

  @override
  State<SidebarNav> createState() => _SidebarNavState();
}

class _SidebarNavState extends State<SidebarNav> {
  final Map<NavSection, bool> _expandedMenus = {
    NavSection.manage: false,
    NavSection.leads: false,
    NavSection.reports: false,
  };

  OverlayEntry? _flyoutOverlay;

  final List<NavItem> _navItems = const [
    NavItem(
      section: NavSection.dashboard,
      title: 'Dashboard',
      icon: Icons.speed_rounded,
    ),
    NavItem(
      section: NavSection.manage,
      title: 'Manage',
      icon: Icons.settings_outlined,
      subItems: NavMenuData.manageOptions,
    ),
    NavItem(
      section: NavSection.leads,
      title: 'Leads',
      icon: Icons.filter_alt_outlined,
      subItems: NavMenuData.leadsOptions,
    ),
    NavItem(
      section: NavSection.reports,
      title: 'Reports',
      icon: Icons.assignment_outlined,
      subItems: NavMenuData.reportsOptions,
    ),
    NavItem(
      section: NavSection.settings,
      title: 'Settings',
      icon: Icons.tune_rounded,
    ),
    NavItem(
      section: NavSection.help,
      title: 'Help',
      icon: Icons.help_outline_rounded,
    ),
  ];

  void _removeFlyout() {
    _flyoutOverlay?.remove();
    _flyoutOverlay = null;
  }

  void _showFlyout(BuildContext context, NavItem item, Offset targetPosition) {
    _removeFlyout();
    if (item.subItems == null || item.subItems!.isEmpty) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _flyoutOverlay = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeFlyout,
            ),
          ),
          Positioned(
            left: 78,
            top: targetPosition.dy.clamp(10.0, MediaQuery.of(context).size.height - 400.0),
            child: NavDropdownMenu(
              title: item.title,
              items: item.subItems!,
              selectedSubItemId: widget.selectedSection == item.section ? widget.selectedSubItemId : null,
              onSelect: (sub) {
                widget.onSubItemSelected(item.section, sub.id);
                _removeFlyout();
              },
              onClose: _removeFlyout,
            ),
          ),
        ],
      ),
    );

    overlay.insert(_flyoutOverlay!);
  }

  @override
  void dispose() {
    _removeFlyout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = widget.isCollapsed ? 76.0 : 230.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeInOut,
      width: width,
      decoration: const BoxDecoration(
        color: AppColors.sidebarBackground,
        border: Border(
          right: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Brand Logo Header
          Container(
            height: 72,
            padding: EdgeInsets.symmetric(horizontal: widget.isCollapsed ? 18 : 20),
            alignment: Alignment.centerLeft,
            child: BrandLogo(
              isCollapsed: widget.isCollapsed,
              size: 36,
            ),
          ),
          const Divider(height: 1),

          // Nav Menu Items List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _navItems.length,
              itemBuilder: (context, index) {
                final item = _navItems[index];
                final isSelected = widget.selectedSection == item.section;
                final hasSubItems = item.subItems != null && item.subItems!.isNotEmpty;
                final isExpanded = _expandedMenus[item.section] ?? false;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildNavItem(item, isSelected, hasSubItems, isExpanded),
                    if (hasSubItems && isExpanded && !widget.isCollapsed)
                      ...item.subItems!.map((sub) => _buildSubNavItem(item.section, sub)),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Bottom Collapse/Expand Toggle
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _removeFlyout();
                  widget.onToggleCollapse();
                },
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Icon(
                      widget.isCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(NavItem item, bool isSelected, bool hasSubItems, bool isExpanded) {
    return Builder(
      builder: (btnContext) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          child: Tooltip(
            message: widget.isCollapsed ? item.title : '',
            waitDuration: const Duration(milliseconds: 300),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  if (widget.isCollapsed && hasSubItems) {
                    final box = btnContext.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final pos = box.localToGlobal(Offset.zero);
                      _showFlyout(context, item, pos);
                    }
                  } else {
                    widget.onSectionSelected(item.section);
                    if (hasSubItems && !widget.isCollapsed) {
                      setState(() {
                        _expandedMenus[item.section] = !isExpanded;
                      });
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: widget.isCollapsed ? 12 : 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: isSelected
                        ? Border.all(color: AppColors.primary.withValues(alpha: 0.25))
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      ),
                      if (!widget.isCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (hasSubItems)
                          Icon(
                            isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                            size: 16,
                            color: isSelected ? AppColors.primary : AppColors.textMuted,
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubNavItem(NavSection parentSection, NavSubItem sub) {
    final isSelected = widget.selectedSection == parentSection && widget.selectedSubItemId == sub.id;

    return Container(
      margin: const EdgeInsets.only(left: 28, right: 10, top: 1, bottom: 1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            widget.onSubItemSelected(parentSection, sub.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (sub.icon != null) ...[
                  Icon(
                    sub.icon,
                    size: 15,
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    sub.title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

