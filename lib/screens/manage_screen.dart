import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nav_item.dart';
import '../services/connect_code_service.dart';
import '../theme/app_colors.dart';
import '../widgets/sub_section_nav_bar.dart';

class ManageScreen extends StatefulWidget {
  final String? activeSubItemId;
  final ValueChanged<String>? onSubItemSelected;

  const ManageScreen({
    super.key,
    this.activeSubItemId,
    this.onSubItemSelected,
  });

  @override
  State<ManageScreen> createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  late String _selectedSubItem;

  @override
  void initState() {
    super.initState();
    _selectedSubItem = widget.activeSubItemId ?? 'employees';
  }

  @override
  void didUpdateWidget(covariant ManageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubItemId != null && widget.activeSubItemId != _selectedSubItem) {
      setState(() {
        _selectedSubItem = widget.activeSubItemId!;
      });
    }
  }

  void _onSelect(String id) {
    setState(() {
      _selectedSubItem = id;
    });
    if (widget.onSubItemSelected != null) {
      widget.onSubItemSelected!(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubSectionNavBar(
            title: 'Manage',
            description: 'Configure your workforce, privacy exclusions, note templates, message templates, and call records.',
            items: NavMenuData.manageOptions,
            selectedSubItemId: _selectedSubItem,
            onSubItemSelected: _onSelect,
            actionButtons: _buildHeaderActions(),
          ),
          const SizedBox(height: 12),
          _buildActiveView(),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderActions() {
    switch (_selectedSubItem) {
      case 'employees':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddEmployeeDialog(context),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Add Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'exclude_phone_numbers':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddExcludeNumberDialog(context),
            icon: const Icon(Icons.block_rounded, size: 16),
            label: const Text('Exclude New Number'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'users':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddUserDialog(context),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Invite User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'call_note_templates':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddTemplateDialog(context, 'Call Note Template'),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('New Note Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'message_templates':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddTemplateDialog(context, 'Message Template'),
            icon: const Icon(Icons.add_comment_rounded, size: 16),
            label: const Text('New Message Template'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActiveView() {
    switch (_selectedSubItem) {
      case 'employees':
        return _buildEmployeesView();
      case 'exclude_phone_numbers':
        return _buildExcludePhoneNumbersView();
      case 'users':
        return _buildUsersView();
      case 'call_note_templates':
        return _buildCallNoteTemplatesView();
      case 'message_templates':
        return _buildMessageTemplatesView();
      case 'call_recordings':
        return _buildCallRecordingsView();
      case 'call_transcripts':
        return _buildCallTranscriptsView();
      case 'pinned_call_logs':
        return _buildPinnedCallLogsView();
      default:
        return _buildEmployeesView();
    }
  }

  // 1. Employees View
  Widget _buildEmployeesView() {
    final employees = [
      {'name': 'Kushal Asodia', 'email': 'kushal@taksecall.com', 'phone': '+91 88007 19093', 'role': 'Admin & Sales Lead', 'sim': 'SIM 1 (Jio 5G)', 'status': 'Active', 'callsToday': '42 calls'},
      {'name': 'Rahul Sharma', 'email': 'rahul.s@taksecall.com', 'phone': '+91 98250 11223', 'role': 'Sales Executive', 'sim': 'SIM 1 (Airtel 5G)', 'status': 'Active', 'callsToday': '38 calls'},
      {'name': 'Priya Verma', 'email': 'priya.v@taksecall.com', 'phone': '+91 97123 44556', 'role': 'Customer Success', 'sim': 'SIM 2 (Vi)', 'status': 'On Call', 'callsToday': '51 calls'},
      {'name': 'Amit Patel', 'email': 'amit.p@taksecall.com', 'phone': '+91 98980 99887', 'role': 'Lead Qualifier', 'sim': 'SIM 1 (Jio 5G)', 'status': 'Offline', 'callsToday': '19 calls'},
      {'name': 'Sneha Nair', 'email': 'sneha.n@taksecall.com', 'phone': '+91 94230 66778', 'role': 'Support Executive', 'sim': 'SIM 1 + SIM 2', 'status': 'Active', 'callsToday': '47 calls'},
    ];

    return Column(
      children: [
        // Quick Stats Row
        Row(
          children: [
            _statMetricCard('Total Employees', '5 Active', Icons.badge_outlined, AppColors.primary),
            const SizedBox(width: 14),
            _statMetricCard('Connected SIMs', '6 Devices', Icons.phone_android_rounded, AppColors.incoming),
            const SizedBox(width: 14),
            _statMetricCard('Calls Logged Today', '197 Calls', Icons.phone_in_talk_rounded, AppColors.outgoing),
          ],
        ),
        const SizedBox(height: 18),

        // Table Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Employee Roster & SIM Assignments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    SizedBox(
                      width: 220,
                      height: 36,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search employee...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search_rounded, size: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('Employee Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Role / Department', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Assigned SIM', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Calls Today', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: employees.map((emp) {
                          final isActive = emp['status'] == 'Active';
                          final isOnCall = emp['status'] == 'On Call';
                          final statusColor = isActive ? AppColors.incoming : (isOnCall ? AppColors.primary : AppColors.textMuted);
                          final statusBg = isActive ? AppColors.incomingSubtle : (isOnCall ? AppColors.primarySubtle : const Color(0xFFF1F5F9));

                          return DataRow(cells: [
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 14,
                                  backgroundColor: AppColors.primarySubtle,
                                  child: Text(emp['name']!.substring(0, 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(emp['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                    Text(emp['email']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                              ],
                            )),
                            DataCell(Text(emp['role']!, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(emp['phone']!, style: const TextStyle(fontSize: 13))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
                              child: Text(emp['sim']!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            )),
                            DataCell(Text(emp['callsToday']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
                              child: Text(emp['status']!, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                            )),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textSecondary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  splashRadius: 16,
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  splashRadius: 16,
                                  onPressed: () {},
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Exclude Phone Numbers View
  Widget _buildExcludePhoneNumbersView() {
    final excludedNumbers = [
      {'number': '+91 99999 00001', 'label': 'CEO Personal Line', 'reason': 'Personal / Confidential', 'addedBy': 'Kushal Asodia', 'date': '12 Aug 2026'},
      {'number': '+91 98888 11112', 'label': 'Internal Testing Device', 'reason': 'QA & Dev Testing', 'addedBy': 'System Admin', 'date': '05 Aug 2026'},
      {'number': '+91 97777 22223', 'label': 'Bank Verification SMS Sender', 'reason': 'Automated Transaction OTP', 'addedBy': 'Kushal Asodia', 'date': '20 Jul 2026'},
      {'number': '+91 96666 33334', 'label': 'Accounts Department Cell', 'reason': 'Internal Finance Line', 'addedBy': 'Rahul Sharma', 'date': '18 Jun 2026'},
    ];

    return Column(
      children: [
        // Informational Alert Banner
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCA5A5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.shield_outlined, color: Color(0xFFDC2626), size: 24),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Privacy & Do-Not-Track Exclusions Active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF991B1B))),
                    Text('Calls and messages associated with excluded phone numbers will never be recorded, synced, or displayed in company call reports.', style: TextStyle(fontSize: 12, color: Color(0xFF7F1D1D))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Excluded Phone Numbers Directory', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('${excludedNumbers.length} Numbers Excluded', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Divider(height: 1),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Label / Contact Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Exclusion Reason', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Added By', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Date Added', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: excludedNumbers.map((item) {
                          return DataRow(cells: [
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_disabled_rounded, size: 16, color: Color(0xFFDC2626)),
                                const SizedBox(width: 8),
                                Text(item['number']!, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                              ],
                            )),
                            DataCell(Text(item['label']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(6)),
                              child: Text(item['reason']!, style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), fontWeight: FontWeight.w600)),
                            )),
                            DataCell(Text(item['addedBy']!, style: const TextStyle(fontSize: 12))),
                            DataCell(Text(item['date']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFDC2626)),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  splashRadius: 16,
                                  tooltip: 'Remove from exclusion',
                                  onPressed: () {},
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 3. Users View
  Widget _buildUsersView() {
    final users = [
      {'name': 'Kushal Asodia', 'email': 'kushal@taksecall.com', 'role': 'Super Admin', 'mfa': 'Enabled', 'lastLogin': 'Today, 5:10 PM'},
      {'name': 'Rahul Sharma', 'email': 'rahul.s@taksecall.com', 'role': 'Sales Manager', 'mfa': 'Enabled', 'lastLogin': 'Today, 2:40 PM'},
      {'name': 'Priya Verma', 'email': 'priya.v@taksecall.com', 'role': 'Support Lead', 'mfa': 'Disabled', 'lastLogin': 'Yesterday, 6:15 PM'},
      {'name': 'Vikram Mehra', 'email': 'vikram.m@taksecall.com', 'role': 'Analytics Viewer', 'mfa': 'Enabled', 'lastLogin': '24 Aug 2026'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Web Dashboard Users & Access Control', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('User Profile', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Assigned Role', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('2FA Security', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Last Active Session', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: users.map((u) {
                      return DataRow(cells: [
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(radius: 14, backgroundColor: AppColors.primarySubtle, child: Text(u['name']!.substring(0, 1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary))),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                Text(u['email']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                          ],
                        )),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(6)),
                          child: Text(u['role']!, style: const TextStyle(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w600)),
                        )),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(u['mfa'] == 'Enabled' ? Icons.check_circle_rounded : Icons.cancel_rounded, size: 14, color: u['mfa'] == 'Enabled' ? AppColors.incoming : AppColors.missed),
                            const SizedBox(width: 4),
                            Text(u['mfa']!, style: const TextStyle(fontSize: 12)),
                          ],
                        )),
                        DataCell(Text(u['lastLogin']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.security_rounded, size: 16, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              tooltip: 'Edit Permissions',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.more_vert_rounded, size: 16, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              onPressed: () {},
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 4. Call Note Templates View
  Widget _buildCallNoteTemplatesView() {
    final templates = [
      {'title': 'Follow-Up Required Tomorrow', 'tag': 'Follow Up', 'shortcut': '/followup', 'content': 'Client requested quotation details via WhatsApp. Schedule follow-up call tomorrow at 11:00 AM.'},
      {'title': 'Interested in Annual Enterprise Plan', 'tag': 'High Value', 'shortcut': '/enterprise', 'content': 'Decision maker interested in 10+ SIM bundle with custom AI transcription add-on. Sent demo invite.'},
      {'title': 'Call Disconnected / Network Issue', 'tag': 'Retry', 'shortcut': '/disconn', 'content': 'Call dropped after 30 seconds due to network. Queued for auto-redial in 15 minutes.'},
      {'title': 'Price Negotiation in Progress', 'tag': 'Negotiation', 'shortcut': '/price', 'content': 'Client is comparing with competitor. Offered 10% standard early-adopter waiver.'},
      {'title': 'Wrong Contact / Invalid Number', 'tag': 'Invalid', 'shortcut': '/wrong', 'content': 'Person answered stated wrong number or left the organization. Flagged for contact verification.'},
      {'title': 'Closed Won - Payment Link Sent', 'tag': 'Converted', 'shortcut': '/won', 'content': 'Agreed to onboarding. Razorpay invoice payment link shared via SMS and email.'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 380,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 170,
      ),
      itemCount: templates.length,
      itemBuilder: (context, index) {
        final t = templates[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(t['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5), overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                    child: Text(t['shortcut']!, style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Text(t['content']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(12)),
                    child: Text(t['tag']!, style: const TextStyle(fontSize: 10.5, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 15, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        splashRadius: 14,
                        tooltip: 'Copy template text',
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 15, color: AppColors.textMuted),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        splashRadius: 14,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 5. Message Templates View
  Widget _buildMessageTemplatesView() {
    final msgTemplates = [
      {'title': 'Post-Call Follow-up SMS', 'channel': 'SMS / WhatsApp', 'body': 'Hi {{client_name}}, thanks for speaking with {{agent_name}} from Takse Call! You can view our live product demo here: https://taksecall.com/demo. Have a great day!'},
      {'title': 'Missed Call Auto-Responder', 'channel': 'SMS Auto-Reply', 'body': 'Hello! We noticed we missed your call at Takse Call. Our executive {{agent_name}} will connect with you shortly. You can also reach us via WhatsApp at +91 8800719093.'},
      {'title': 'Schedule Demo Meeting Link', 'channel': 'WhatsApp Template', 'body': 'Dear {{client_name}}, please choose a convenient slot for our upcoming analytics walkthrough: {{calendar_link}}. Looking forward to our discussion!'},
      {'title': 'Quotation & Pricing Brochure', 'channel': 'WhatsApp Template', 'body': 'Hi {{client_name}}, as requested, please find attached the Takse Call Multi-SIM Admin Plan proposal. Let us know if you have any questions!'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 440,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 180,
      ),
      itemCount: msgTemplates.length,
      itemBuilder: (context, index) {
        final m = msgTemplates[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(m['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(6)),
                    child: Text(m['channel']!, style: const TextStyle(fontSize: 10.5, color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                  child: Text(m['body']!, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.35)),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.send_rounded, size: 14),
                    label: const Text('Send Test', style: TextStyle(fontSize: 11)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                    splashRadius: 14,
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. Call Recordings View
  Widget _buildCallRecordingsView() {
    final recordings = [
      {'caller': 'Kushal Asodia', 'client': 'Rahul (Tech Corp)', 'phone': '+91 98250 12345', 'duration': '04:12', 'time': 'Today, 3:15 PM', 'size': '3.8 MB', 'quality': 'HD Audio'},
      {'caller': 'Priya Verma', 'client': 'Anita (Design Hub)', 'phone': '+91 97123 45678', 'duration': '02:45', 'time': 'Today, 1:40 PM', 'size': '2.4 MB', 'quality': 'HD Audio'},
      {'caller': 'Rahul Sharma', 'client': 'Vijay (Logistics Pro)', 'phone': '+91 94567 89012', 'duration': '06:30', 'time': 'Yesterday, 5:20 PM', 'size': '5.9 MB', 'quality': 'HD Audio'},
      {'caller': 'Sneha Nair', 'client': 'Rohan (Finance Group)', 'phone': '+91 99000 44556', 'duration': '01:50', 'time': 'Yesterday, 11:10 AM', 'size': '1.7 MB', 'quality': 'HD Audio'},
    ];

    return Column(
      children: [
        // Audio Player Simulation Bar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Recording: Rahul (Tech Corp) - Call Discussion', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('01:45 / 04:12', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11.5, fontFamily: 'monospace')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: 0.42,
                      backgroundColor: const Color(0xFF334155),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 20),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Recordings List Table
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Play', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Client / Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Handled By Agent', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Recorded Time', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Download', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: recordings.map((r) {
                      return DataRow(cells: [
                        DataCell(IconButton(
                          icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.primary, size: 28),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          splashRadius: 18,
                          onPressed: () {},
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(r['client']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(r['phone']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        )),
                        DataCell(Text(r['caller']!, style: const TextStyle(fontSize: 12.5))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_outlined, size: 14, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(r['duration']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                          ],
                        )),
                        DataCell(Text(r['time']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.download_rounded, size: 18, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              tooltip: 'Download MP3',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.share_outlined, size: 16, color: AppColors.textSecondary),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              onPressed: () {},
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 7. Call Transcripts View
  Widget _buildCallTranscriptsView() {
    final transcripts = [
      {
        'contact': 'Rahul Sharma (Tech Corp)',
        'agent': 'Kushal Asodia',
        'duration': '3m 45s',
        'sentiment': 'Positive (92%)',
        'summary': 'Discussed multi-user enterprise license rollout. Client agreed to start 5-device trial.',
        'dialogue': [
          {'speaker': 'Agent', 'time': '00:04', 'text': 'Hello Rahul, this is Kushal from Takse Call. How is your call tracking setup going?'},
          {'speaker': 'Client', 'time': '00:15', 'text': 'Hi Kushal, we really like the automatic SIM sync! We want to connect 5 more sales devices.'},
          {'speaker': 'Agent', 'time': '00:32', 'text': 'That is great to hear! I can enable the multi-device connect codes for your team right away.'},
        ],
      },
      {
        'contact': 'Priya Verma (Design Studio)',
        'agent': 'Sneha Nair',
        'duration': '2m 10s',
        'sentiment': 'Neutral (75%)',
        'summary': 'Inquired about export formats and WhatsApp automation trigger options.',
        'dialogue': [
          {'speaker': 'Agent', 'time': '00:02', 'text': 'Good afternoon Priya, thanks for taking my call.'},
          {'speaker': 'Client', 'time': '00:10', 'text': 'Can we export call recordings directly to Excel sheets?'},
          {'speaker': 'Agent', 'time': '00:20', 'text': 'Yes! You can download CSV reports with full duration timestamps from the reports tab.'},
        ],
      },
    ];

    return Column(
      children: transcripts.map((t) {
        final dialogue = t['dialogue'] as List<Map<String, String>>;
        return Container(
          margin: const EdgeInsets.only(bottom: 18),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.transcribe_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(t['contact'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                    child: Text(t['sentiment'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text('Handled by ${t['agent']} • Duration: ${t['duration']}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Text('AI Summary: ${t['summary']}', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
              ),
              const SizedBox(height: 14),
              const Text('Transcript Dialogue', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              ...dialogue.map((d) {
                final isAgent = d['speaker'] == 'Agent';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 54,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: isAgent ? AppColors.primarySubtle : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                        child: Text(d['speaker']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAgent ? AppColors.primary : AppColors.textSecondary)),
                      ),
                      const SizedBox(width: 8),
                      Text(d['time']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'monospace')),
                      const SizedBox(width: 10),
                      Expanded(child: Text(d['text']!, style: const TextStyle(fontSize: 12.5, height: 1.3))),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 8. Pinned Call Logs View
  Widget _buildPinnedCallLogsView() {
    final pinned = [
      {'caller': 'Kushal Asodia', 'client': 'Vikram Mehra (Enterprise Deal)', 'phone': '+91 99887 66554', 'priority': 'URGENT', 'note': 'High-ticket annual contract renewal pending signature today by 6 PM.', 'time': 'Today, 11:30 AM'},
      {'caller': 'Rahul Sharma', 'client': 'Suresh Logistics (Custom Integration)', 'phone': '+91 98765 43210', 'priority': 'HIGH', 'note': 'Client requested dedicated SIM pairing extension API keys.', 'time': 'Yesterday, 4:00 PM'},
      {'caller': 'Priya Verma', 'client': 'Deepak Trading (VIP)', 'phone': '+91 91234 56789', 'priority': 'MEDIUM', 'note': 'Special discount approved by management. Ready to send payment link.', 'time': '23 Aug, 2:15 PM'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.push_pin_rounded, color: Color(0xFFF59E0B), size: 20),
                SizedBox(width: 8),
                Text('Pinned High-Priority Call Logs & Action Notes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Priority', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Contact / Organization', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Pinned Note', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Date / Time', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: pinned.map((p) {
                      final isUrgent = p['priority'] == 'URGENT';
                      return DataRow(cells: [
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text(p['priority']!, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFFD97706))),
                        )),
                        DataCell(Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(p['client']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(p['phone']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        )),
                        DataCell(SizedBox(width: 240, child: Text(p['note']!, style: const TextStyle(fontSize: 12, height: 1.3), overflow: TextOverflow.ellipsis, maxLines: 2))),
                        DataCell(Text(p['caller']!, style: const TextStyle(fontSize: 12.5))),
                        DataCell(Text(p['time']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                        DataCell(Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 18, color: AppColors.incoming),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              tooltip: 'Mark resolved',
                              onPressed: () {},
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: const Icon(Icons.push_pin_outlined, size: 18, color: AppColors.textMuted),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              splashRadius: 16,
                              tooltip: 'Unpin',
                              onPressed: () {},
                            ),
                          ],
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _statMetricCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dialog helpers
  void _showAddEmployeeDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final roleCtrl = TextEditingController(text: 'Sales Executive');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Add New Employee & Generate Code'),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter team member details to generate their unique mobile pairing code.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'e.g. Amit Kumar',
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                decoration: InputDecoration(
                  labelText: 'Phone Number (For Tracking)',
                  hintText: 'e.g. +91 98765 43210',
                  prefixIcon: const Icon(Icons.phone_iphone_rounded, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'e.g. amit.k@company.com',
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleCtrl,
                decoration: InputDecoration(
                  labelText: 'Role / Designation',
                  prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final empName = nameCtrl.text.trim();
              if (empName.isEmpty) return;

              final code = ConnectCodeService.generateCode(empName);
              Navigator.pop(ctx);

              // Show Success Modal with Device Connect Code
              showDialog(
                context: context,
                builder: (codeCtx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppColors.incoming),
                      SizedBox(width: 8),
                      Text('Employee Added!'),
                    ],
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Device Connect Code for $empName:', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              code,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.connectCodeText),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.connectCodeText),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: code));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Employee code "$code" copied to clipboard!'),
                                    backgroundColor: AppColors.primary,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Share this code with your employee to enter into the Takse Call Mobile App.',
                        style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(codeCtx), child: const Text('Done')),
                  ],
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Generate Code & Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExcludeNumberDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Phone Number to Exclude'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Phone Number (e.g. +91 99999 11111)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Label / Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Reason for Exclusion', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number excluded from tracking.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: const Text('Exclude Number'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Invite Web Dashboard User'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'User Email', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Role (Admin / Manager / Viewer)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invitation email sent.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Send Invitation'),
          ),
        ],
      ),
    );
  }

  void _showAddTemplateDialog(BuildContext context, String templateType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('New $templateType'),
        content: SizedBox(
          width: 450,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Template Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(labelText: 'Template Content / Body', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$templateType created successfully.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save Template'),
          ),
        ],
      ),
    );
  }
}
