import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import '../widgets/floating_chat_button.dart';
import '../widgets/footer_bar.dart';
import '../widgets/sidebar_nav.dart';
import '../widgets/top_header_bar.dart';
import 'dashboard_screen.dart';
import 'help_screen.dart';
import 'leads_screen.dart';
import 'manage_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';

import '../services/web_auth_service.dart';

class MainShell extends StatefulWidget {
  final VoidCallback? onLogout;

  const MainShell({super.key, this.onLogout});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  NavSection _selectedSection = NavSection.dashboard;
  bool _isSidebarCollapsed = false;

  String _selectedManageSubItem = 'employees';
  String _selectedLeadsSubItem = 'my_leads';
  String _selectedReportsSubItem = 'periodic_reports';

  void _onSectionSelected(NavSection section) {
    setState(() {
      _selectedSection = section;
    });
  }

  void _onSubItemSelected(NavSection section, String subItemId) {
    setState(() {
      _selectedSection = section;
      if (section == NavSection.manage) {
        _selectedManageSubItem = subItemId;
      } else if (section == NavSection.leads) {
        _selectedLeadsSubItem = subItemId;
      } else if (section == NavSection.reports) {
        _selectedReportsSubItem = subItemId;
      }
    });
  }

  String? _getCurrentSubItemId() {
    switch (_selectedSection) {
      case NavSection.manage:
        return _selectedManageSubItem;
      case NavSection.leads:
        return _selectedLeadsSubItem;
      case NavSection.reports:
        return _selectedReportsSubItem;
      default:
        return null;
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out from Takse Call Web?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.of(context).pop();
              await WebAuthService.signOut();
              if (widget.onLogout != null) {
                widget.onLogout!();
              }
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.missed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPage() {
    switch (_selectedSection) {
      case NavSection.dashboard:
        return const DashboardScreen();
      case NavSection.manage:
        return ManageScreen(
          activeSubItemId: _selectedManageSubItem,
          onSubItemSelected: (id) => setState(() => _selectedManageSubItem = id),
        );
      case NavSection.leads:
        return LeadsScreen(
          activeSubItemId: _selectedLeadsSubItem,
          onSubItemSelected: (id) => setState(() => _selectedLeadsSubItem = id),
        );
      case NavSection.reports:
        return ReportsScreen(
          activeSubItemId: _selectedReportsSubItem,
          onSubItemSelected: (id) => setState(() => _selectedReportsSubItem = id),
        );
      case NavSection.settings:
        return const SettingsScreen();
      case NavSection.help:
        return const HelpScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = WebAuthService.currentUser;
    final currentUserName = user?.name ?? 'Rohan Sharma';
    final currentDeviceCode = user?.connectCode ?? 'ROH-3453-2342';

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Stack(
        children: [
          Row(
            children: [
              // Left Collapsible Sidebar Navigation
              SidebarNav(
                selectedSection: _selectedSection,
                selectedSubItemId: _getCurrentSubItemId(),
                onSectionSelected: _onSectionSelected,
                onSubItemSelected: _onSubItemSelected,
                isCollapsed: _isSidebarCollapsed,
                onToggleCollapse: _toggleSidebar,
              ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Header Bar
                    TopHeaderBar(
                      userName: currentUserName,
                      deviceCode: currentDeviceCode,
                      onLogout: _handleLogout,
                    ),

                    // Scrollable Page Content + Footer
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildCurrentPage(),
                            const FooterBar(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Floating Support Chat Widget at Bottom Right
          const Positioned(
            right: 24,
            bottom: 24,
            child: FloatingChatButton(),
          ),
        ],
      ),
    );
  }
}

