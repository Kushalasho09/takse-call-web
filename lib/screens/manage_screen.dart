import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import '../widgets/register_employee_view.dart';
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
  bool _isRegisteringEmployee = false;
  final String _deviceConnectCode = 'ASH-3426-0915';

  bool _showTrashedEmployees = false;
  bool _showEmployeesWithSyncIssue = false;
  int _pageSize = 50;
  bool _selectAll = false;
  final Set<int> _selectedRowIds = {};

  final TextEditingController _searchEmployeeCtrl = TextEditingController();
  final TextEditingController _searchCodeCtrl = TextEditingController();
  final TextEditingController _searchTagCtrl = TextEditingController();
  final TextEditingController _searchModelCtrl = TextEditingController();
  final TextEditingController _searchVersionCtrl = TextEditingController();

  final TextEditingController _searchContactNameCtrl = TextEditingController();
  final TextEditingController _searchContactNumberCtrl = TextEditingController();
  int _excludePageSize = 50;
  bool _selectAllExcluded = false;
  final Set<int> _selectedExcludedIds = {};
  late List<Map<String, dynamic>> _excludedNumbersList;

  late List<Map<String, dynamic>> _employeeRoster;

  @override
  void initState() {
    super.initState();
    _selectedSubItem = widget.activeSubItemId ?? 'employees';
    _employeeRoster = [
      {
        'id': 1,
        'name': 'vishal',
        'phone': '+91-8800719093',
        'code': '',
        'tags': <String>[],
        'model': 'OPPO CPH2761',
        'version': '2.17.2',
        'registeredDate': '15 Sep 2026, 10:21 PM',
        'lastCallTime': '16 Sep 2026, 04:47 PM',
        'lastSyncTime': '16 Sep 2026, 05:14 PM',
        'leadEnabled': false,
        'recordingEnabled': true,
        'hasWarning': true,
        'isLocked': false, // green unlocked padlock
        'isTrashed': false,
        'hasSyncIssue': false,
      },
      {
        'id': 2,
        'name': 'kushal asodia',
        'phone': '+91-9664579043',
        'code': '',
        'tags': <String>[],
        'model': 'OPPO CPH2495',
        'version': '2.17.2',
        'registeredDate': '15 Sep 2026, 10:24 PM',
        'lastCallTime': '15 Sep 2026, 10:24 PM',
        'lastSyncTime': '16 Sep 2026, 04:41 PM',
        'leadEnabled': false,
        'recordingEnabled': true,
        'hasWarning': true,
        'isLocked': true, // red locked padlock
        'isTrashed': false,
        'hasSyncIssue': false,
      },
    ];

    _excludedNumbersList = [
      {
        'id': 1,
        'contactName': 'CEO Personal Line',
        'contactNumber': '+91 99999 00001',
      },
      {
        'id': 2,
        'contactName': 'Internal Testing Device',
        'contactNumber': '+91 98888 11112',
      },
      {
        'id': 3,
        'contactName': 'Bank Verification SMS Sender',
        'contactNumber': '+91 97777 22223',
      },
      {
        'id': 4,
        'contactName': 'Accounts Department Cell',
        'contactNumber': '+91 96666 33334',
      },
    ];
  }

  @override
  void dispose() {
    _searchEmployeeCtrl.dispose();
    _searchCodeCtrl.dispose();
    _searchTagCtrl.dispose();
    _searchModelCtrl.dispose();
    _searchVersionCtrl.dispose();
    _searchContactNameCtrl.dispose();
    _searchContactNumberCtrl.dispose();
    super.dispose();
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
            onPressed: () => setState(() => _isRegisteringEmployee = true),
            icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
            label: const Text('Register Employee'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
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

  // 1. Employees View (Matches User Images Pixel-Perfect)
  Widget _buildEmployeesView() {
    if (_isRegisteringEmployee) {
      return RegisterEmployeeView(
        onBack: () => setState(() => _isRegisteringEmployee = false),
        connectCode: _deviceConnectCode,
      );
    }

    final empFilter = _searchEmployeeCtrl.text.toLowerCase().trim();
    final codeFilter = _searchCodeCtrl.text.toLowerCase().trim();
    final tagFilter = _searchTagCtrl.text.toLowerCase().trim();
    final modelFilter = _searchModelCtrl.text.toLowerCase().trim();
    final verFilter = _searchVersionCtrl.text.toLowerCase().trim();

    final filteredList = _employeeRoster.where((emp) {
      if (!_showTrashedEmployees && (emp['isTrashed'] == true)) return false;
      if (_showEmployeesWithSyncIssue && !(emp['hasSyncIssue'] == true)) return false;

      if (empFilter.isNotEmpty) {
        final matchName = emp['name'].toString().toLowerCase().contains(empFilter);
        final matchPhone = emp['phone'].toString().toLowerCase().contains(empFilter);
        if (!matchName && !matchPhone) return false;
      }
      if (codeFilter.isNotEmpty && !emp['code'].toString().toLowerCase().contains(codeFilter)) {
        return false;
      }
      if (tagFilter.isNotEmpty) {
        final tags = (emp['tags'] as List<String>).join(' ').toLowerCase();
        if (!tags.contains(tagFilter)) return false;
      }
      if (modelFilter.isNotEmpty && !emp['model'].toString().toLowerCase().contains(modelFilter)) {
        return false;
      }
      if (verFilter.isNotEmpty && !emp['version'].toString().toLowerCase().contains(verFilter)) {
        return false;
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Title & Connect Code Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title and Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Employees',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 14, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        const Text(
                          'Manage phone numbers operated by your employees.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),

                // Device Connect Code Pill + Help + Export
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    // Connect Code Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Your device connect code is ',
                            style: TextStyle(fontSize: 12, color: Color(0xFF475569)),
                          ),
                          Text(
                            _deviceConnectCode,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFD97706),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: _deviceConnectCode));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Device connect code copied!'),
                                  backgroundColor: Color(0xFFF97316),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: const Icon(Icons.copy_rounded, size: 13, color: Color(0xFFD97706)),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => setState(() => _isRegisteringEmployee = true),
                            child: const Icon(Icons.share_outlined, size: 13, color: Color(0xFFD97706)),
                          ),
                        ],
                      ),
                    ),

                    // HELP Menu
                    PopupMenuButton<String>(
                      tooltip: 'Help',
                      onSelected: (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Opening $val...')),
                        );
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'Schedule a Demo', child: Text('Schedule a Demo')),
                        const PopupMenuItem(value: 'Documentation', child: Text('Documentation')),
                        const PopupMenuItem(value: 'Contact Support', child: Text('Contact Support')),
                      ],
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.help_outline_rounded, size: 15, color: Color(0xFF475569)),
                          SizedBox(width: 4),
                          Text('HELP', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF475569)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16, child: VerticalDivider(width: 1, color: AppColors.border)),

                    // EXPORT Menu
                    PopupMenuButton<String>(
                      tooltip: 'Export',
                      onSelected: (val) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Exporting employees to $val...'),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(value: 'Excel (.xlsx)', child: Text('Export to Excel (.xlsx)')),
                        const PopupMenuItem(value: 'CSV (.csv)', child: Text('Export to CSV (.csv)')),
                      ],
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.file_download_outlined, size: 16, color: Color(0xFF475569)),
                          SizedBox(width: 4),
                          Text('EXPORT', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                          Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF475569)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Total Employees Row + Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    children: [
                      const TextSpan(text: 'Total Employees : '),
                      TextSpan(
                        text: '${filteredList.length} of 5',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // Show Trashed Employees Checkbox
                InkWell(
                  onTap: () => setState(() => _showTrashedEmployees = !_showTrashedEmployees),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showTrashedEmployees,
                        onChanged: (v) => setState(() => _showTrashedEmployees = v ?? false),
                        activeColor: const Color(0xFFF97316),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text('Show Trashed Employees', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
                    ],
                  ),
                ),
                const SizedBox(width: 20),

                // Show Employees having Sync Issue Checkbox
                InkWell(
                  onTap: () => setState(() => _showEmployeesWithSyncIssue = !_showEmployeesWithSyncIssue),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _showEmployeesWithSyncIssue,
                        onChanged: (v) => setState(() => _showEmployeesWithSyncIssue = v ?? false),
                        activeColor: const Color(0xFFF97316),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      const Text('Show Employees having Sync Issue', style: TextStyle(fontSize: 12.5, color: Color(0xFF475569))),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Top Action Row (+ Register Employee & Show 50 dropdown)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Register Employee Button
                OutlinedButton.icon(
                  onPressed: () => setState(() => _isRegisteringEmployee = true),
                  icon: const Icon(Icons.person_add_alt_outlined, size: 16, color: Color(0xFFF97316)),
                  label: const Text(
                    'Register Employee',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF97316), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 14),

                // Show 50 dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _pageSize,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          items: [10, 25, 50, 100].map((size) {
                            return DropdownMenuItem<int>(
                              value: size,
                              child: Text('$size', style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _pageSize = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Detailed Table with 2-level header
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 1280),
              child: Column(
                children: [
                  // Row 1: Main Headers
                  Container(
                    color: const Color(0xFFF8FAFC),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    child: Row(
                      children: [
                        _tableCell(
                          width: 48,
                          child: Checkbox(
                            value: _selectAll,
                            onChanged: (v) {
                              setState(() {
                                _selectAll = v ?? false;
                                if (_selectAll) {
                                  _selectedRowIds.addAll(filteredList.map((e) => e['id'] as int));
                                } else {
                                  _selectedRowIds.clear();
                                }
                              });
                            },
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                        _tableCell(width: 60, child: _headerTitle('Sr. No.')),
                        _tableCell(width: 190, child: _headerTitle('Employee', sortable: true)),
                        _tableCell(width: 100, child: _headerTitle('Employee Code', sortable: true)),
                        _tableCell(width: 110, child: _headerTitle('Tags')),
                        _tableCell(width: 130, child: _headerTitle('Model Name', sortable: true)),
                        _tableCell(width: 90, child: _headerTitle('App Version', sortable: true)),
                        _tableCell(width: 140, child: _headerTitle('Registered Date', sortable: true)),
                        _tableCell(width: 140, child: _headerTitle('Last Call Time', info: true, sortable: true)),
                        _tableCell(width: 140, child: _headerTitle('Last Sync Time', info: true, sortable: true)),
                        _tableCell(width: 100, child: _headerTitle('Lead Enabled')),
                        _tableCell(width: 130, child: _headerTitle('Call Recording Sync Enabled')),
                        _tableCell(width: 60, child: _headerTitle('Action')),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Row 2: Filter TextFields under corresponding columns
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                    child: Row(
                      children: [
                        _tableCell(width: 48, child: const SizedBox.shrink()),
                        _tableCell(width: 60, child: const SizedBox.shrink()),
                        _tableCell(width: 190, child: _filterInput(_searchEmployeeCtrl, 'Search')),
                        _tableCell(width: 100, child: _filterInput(_searchCodeCtrl, 'Sea')),
                        _tableCell(width: 110, child: _filterInput(_searchTagCtrl, 'Search')),
                        _tableCell(width: 130, child: _filterInput(_searchModelCtrl, 'Sear')),
                        _tableCell(width: 90, child: _filterInput(_searchVersionCtrl, 'Sea')),
                        _tableCell(width: 140, child: const SizedBox.shrink()),
                        _tableCell(width: 140, child: const SizedBox.shrink()),
                        _tableCell(width: 140, child: const SizedBox.shrink()),
                        _tableCell(width: 100, child: const SizedBox.shrink()),
                        _tableCell(width: 130, child: const SizedBox.shrink()),
                        _tableCell(width: 60, child: const SizedBox.shrink()),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.border),

                  // Table Body Rows
                  if (filteredList.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(36),
                      alignment: Alignment.center,
                      child: const Text('No employees found matching filter.', style: TextStyle(color: AppColors.textSecondary)),
                    )
                  else
                    for (int i = 0; i < filteredList.length; i++) ...[
                      _buildEmployeeTableRow(filteredList[i], i + 1),
                      const Divider(height: 1, color: AppColors.border),
                    ],
                ],
              ),
            ),
          ),

          // Bottom Pagination Bar (Matches Image 1: 1 - 2 of 2 < >)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  filteredList.isEmpty ? '0 - 0 of 0' : '1 - ${filteredList.length} of ${filteredList.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      onPressed: () {},
                      splashRadius: 18,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      onPressed: () {},
                      splashRadius: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableCell({required double width, required Widget child}) {
    return SizedBox(
      width: width,
      child: child,
    );
  }

  Widget _headerTitle(String title, {bool sortable = false, bool info = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (info) ...[
          const SizedBox(width: 3),
          const Icon(Icons.info_outline_rounded, size: 12, color: Color(0xFFF59E0B)),
        ],
        if (sortable) ...[
          const SizedBox(width: 3),
          const Icon(Icons.unfold_more_rounded, size: 14, color: Color(0xFF94A3B8)),
        ],
      ],
    );
  }

  Widget _filterInput(TextEditingController controller, String hint) {
    return Container(
      height: 30,
      margin: const EdgeInsets.only(right: 10),
      child: TextField(
        controller: controller,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 11),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          suffixIcon: const Icon(Icons.search_rounded, size: 14, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: Color(0xFFF97316)),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeTableRow(Map<String, dynamic> emp, int index) {
    final empId = emp['id'] as int;
    final isSelected = _selectedRowIds.contains(empId);
    final tags = emp['tags'] as List<String>;

    return Container(
      color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          // Select Checkbox
          _tableCell(
            width: 48,
            child: Checkbox(
              value: isSelected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedRowIds.add(empId);
                  } else {
                    _selectedRowIds.remove(empId);
                  }
                });
              },
              activeColor: const Color(0xFFF97316),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          // Sr. No.
          _tableCell(
            width: 60,
            child: Text('$index', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
          ),

          // Employee Name & Phone
          _tableCell(
            width: 190,
            child: Text(
              '${emp['name']} (${emp['phone']})',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Employee Code
          _tableCell(
            width: 100,
            child: Text(
              (emp['code'] as String).isEmpty ? '-' : emp['code'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
          ),

          // Tags
          _tableCell(
            width: 110,
            child: tags.isEmpty
                ? InkWell(
                    onTap: () => _showAddTagDialog(emp),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_offer_outlined, size: 13, color: Color(0xFFF97316)),
                        SizedBox(width: 4),
                        Text(
                          'Add Tag',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFF97316),
                          ),
                        ),
                      ],
                    ),
                  )
                : Wrap(
                    spacing: 4,
                    children: tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFF59E0B)),
                        ),
                        child: Text(
                          t,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF92400E)),
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // Model Name
          _tableCell(
            width: 130,
            child: Text(
              emp['model'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontWeight: FontWeight.w500),
            ),
          ),

          // App Version
          _tableCell(
            width: 90,
            child: Text(
              emp['version'],
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
          ),

          // Registered Date
          _tableCell(
            width: 140,
            child: Text(
              emp['registeredDate'],
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
            ),
          ),

          // Last Call Time
          _tableCell(
            width: 140,
            child: Text(
              emp['lastCallTime'],
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
            ),
          ),

          // Last Sync Time
          _tableCell(
            width: 140,
            child: Text(
              emp['lastSyncTime'],
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)),
            ),
          ),

          // Lead Enabled Toggle
          _tableCell(
            width: 100,
            child: Switch(
              value: emp['leadEnabled'] as bool,
              onChanged: (val) {
                setState(() {
                  emp['leadEnabled'] = val;
                });
              },
              activeTrackColor: const Color(0xFFF59E0B),
              activeThumbColor: Colors.white,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          // Call Recording Sync Enabled (Toggle + Warning Icon + Padlock)
          _tableCell(
            width: 130,
            child: Row(
              children: [
                Switch(
                  value: emp['recordingEnabled'] as bool,
                  onChanged: (val) {
                    setState(() {
                      emp['recordingEnabled'] = val;
                    });
                  },
                  activeTrackColor: const Color(0xFFFDE68A),
                  activeThumbColor: const Color(0xFFF59E0B),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                if (emp['hasWarning'] == true) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFDC2626)),
                ],
                const SizedBox(width: 4),
                Icon(
                  emp['isLocked'] == true ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                  size: 15,
                  color: emp['isLocked'] == true ? const Color(0xFFDC2626) : const Color(0xFF10B981),
                ),
              ],
            ),
          ),

          // Action Menu
          _tableCell(
            width: 60,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF64748B)),
              splashRadius: 18,
              onSelected: (action) {
                if (action == 'tag') {
                  _showAddTagDialog(emp);
                } else if (action == 'trash') {
                  setState(() => emp['isTrashed'] = true);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${emp['name']} moved to trash.')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$action action performed for ${emp['name']}')),
                  );
                }
              },
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 'Edit Employee', child: Text('Edit Employee')),
                const PopupMenuItem(value: 'tag', child: Text('Add / Manage Tags')),
                const PopupMenuItem(value: 'Sync Call Logs', child: Text('Force Sync Call Logs')),
                const PopupMenuItem(value: 'trash', child: Text('Move to Trash', style: TextStyle(color: Colors.red))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(Map<String, dynamic> emp) {
    final tagCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Add Tag to ${emp['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter tag name or select a recommended tag:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: tagCtrl,
              decoration: InputDecoration(
                hintText: 'e.g. Sales, Onfield, VIP',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              children: ['Sales', 'Field Agent', 'Support', 'VIP Lead'].map((tag) {
                return ActionChip(
                  label: Text(tag, style: const TextStyle(fontSize: 11)),
                  onPressed: () {
                    tagCtrl.text = tag;
                  },
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newTag = tagCtrl.text.trim();
              if (newTag.isNotEmpty) {
                setState(() {
                  (emp['tags'] as List<String>).add(newTag);
                });
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Tag'),
          ),
        ],
      ),
    );
  }

  // 2. Exclude Phone Numbers View (Matches Screenshot Pixel-Perfect)
  Widget _buildExcludePhoneNumbersView() {
    final nameFilter = _searchContactNameCtrl.text.toLowerCase().trim();
    final numberFilter = _searchContactNumberCtrl.text.toLowerCase().trim();

    final filteredList = _excludedNumbersList.where((item) {
      if (nameFilter.isNotEmpty && !item['contactName'].toString().toLowerCase().contains(nameFilter)) {
        return false;
      }
      if (numberFilter.isNotEmpty && !item['contactNumber'].toString().toLowerCase().contains(numberFilter)) {
        return false;
      }
      return true;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Title & Info Subtitle
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Exclude Phone Numbers',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 14, color: Colors.orange.shade700),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'The numbers you will add here will be automatically excluded from all the reports. However, call logs will be synchronized for these numbers. Maximum 1500 numbers can be excluded.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Action Bar: Add Number, Import Numbers, Show 50 dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add Number Button
                OutlinedButton.icon(
                  onPressed: () => _showAddExcludeNumberDialog(context),
                  icon: const Icon(Icons.person_add_alt_outlined, size: 16, color: Color(0xFFF97316)),
                  label: const Text(
                    'Add Number',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF97316), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 12),

                // Import Numbers Button
                OutlinedButton.icon(
                  onPressed: () => _showImportExcludeNumbersDialog(context),
                  icon: const Icon(Icons.file_download_outlined, size: 16, color: Color(0xFFF97316)),
                  label: const Text(
                    'Import Numbers',
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF97316)),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF97316), width: 1.2),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                ),
                const SizedBox(width: 14),

                // Show 50 dropdown
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Show', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: _excludePageSize,
                          icon: const Icon(Icons.arrow_drop_down, size: 18),
                          items: [10, 25, 50, 100].map((size) {
                            return DropdownMenuItem<int>(
                              value: size,
                              child: Text('$size', style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _excludePageSize = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Double Header Table
          LayoutBuilder(
            builder: (context, constraints) {
              final availableWidth = constraints.maxWidth;
              const selectWidth = 80.0;
              const actionWidth = 110.0;
              final colWidth = ((availableWidth - selectWidth - actionWidth - 40) / 2).clamp(280.0, 600.0);
              final minTableWidth = selectWidth + (colWidth * 2) + actionWidth + 40;

              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: minTableWidth),
                  child: Column(
                    children: [
                      // Row 1: Column Titles
                      Container(
                        color: const Color(0xFFF8FAFC),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        child: Row(
                          children: [
                            _tableCell(
                              width: selectWidth,
                              child: const Text('Select', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            ),
                            _tableCell(
                              width: colWidth,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Contact Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_drop_up_rounded, size: 18, color: Color(0xFF94A3B8)),
                                ],
                              ),
                            ),
                            _tableCell(
                              width: colWidth,
                              child: const Text('Contact Number', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            ),
                            _tableCell(
                              width: actionWidth,
                              child: const Text('Action', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),

                      // Row 2: Search Filters
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
                        child: Row(
                          children: [
                            _tableCell(
                              width: selectWidth,
                              child: Checkbox(
                                value: _selectAllExcluded,
                                onChanged: (v) {
                                  setState(() {
                                    _selectAllExcluded = v ?? false;
                                    if (_selectAllExcluded) {
                                      _selectedExcludedIds.addAll(filteredList.map((e) => e['id'] as int));
                                    } else {
                                      _selectedExcludedIds.clear();
                                    }
                                  });
                                },
                                activeColor: const Color(0xFFF97316),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            _tableCell(
                              width: colWidth,
                              child: _filterInput(_searchContactNameCtrl, 'Sear'),
                            ),
                            _tableCell(
                              width: colWidth,
                              child: _filterInput(_searchContactNumberCtrl, 'Search'),
                            ),
                            _tableCell(
                              width: actionWidth,
                              child: const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),

                      // Body Rows
                      if (filteredList.isEmpty)
                        Container(
                          width: minTableWidth,
                          padding: const EdgeInsets.all(36),
                          alignment: Alignment.center,
                          child: const Text('No excluded numbers found matching search.', style: TextStyle(color: AppColors.textSecondary)),
                        )
                      else
                        for (int i = 0; i < filteredList.length; i++) ...[
                          _buildExcludedNumberRow(filteredList[i], selectWidth, colWidth, actionWidth),
                          const Divider(height: 1, color: AppColors.border),
                        ],
                    ],
                  ),
                ),
              );
            },
          ),

          // Bottom Pagination Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  filteredList.isEmpty ? '0 - 0 of 0' : '1 - ${filteredList.length} of ${filteredList.length}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left_rounded, size: 20),
                      onPressed: () {},
                      splashRadius: 18,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right_rounded, size: 20),
                      onPressed: () {},
                      splashRadius: 18,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExcludedNumberRow(Map<String, dynamic> item, double selectWidth, double colWidth, double actionWidth) {
    final itemId = item['id'] as int;
    final isSelected = _selectedExcludedIds.contains(itemId);

    return Container(
      color: isSelected ? const Color(0xFFFFFBEB) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          // Select Checkbox
          _tableCell(
            width: selectWidth,
            child: Checkbox(
              value: isSelected,
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedExcludedIds.add(itemId);
                  } else {
                    _selectedExcludedIds.remove(itemId);
                  }
                });
              },
              activeColor: const Color(0xFFF97316),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),

          // Contact Name
          _tableCell(
            width: colWidth,
            child: Text(
              item['contactName'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          // Contact Number
          _tableCell(
            width: colWidth,
            child: Text(
              item['contactNumber'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF334155),
              ),
            ),
          ),

          // Action Menu
          _tableCell(
            width: actionWidth,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  tooltip: 'Edit',
                  onPressed: () => _showEditExcludeNumberDialog(item),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                  splashRadius: 16,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  tooltip: 'Remove',
                  onPressed: () {
                    setState(() {
                      _excludedNumbersList.removeWhere((e) => e['id'] == itemId);
                      _selectedExcludedIds.remove(itemId);
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${item['contactName']} removed from exclusions.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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

  // Dialog helpers

  void _showAddExcludeNumberDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    final numberCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_outlined, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Add Exclude Phone Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The number added here will be automatically excluded from all calling reports.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  hintText: 'e.g. CEO Personal Line',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberCtrl,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  hintText: 'e.g. +91 99999 00001',
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
              final name = nameCtrl.text.trim();
              final phone = numberCtrl.text.trim();
              if (phone.isEmpty) return;

              setState(() {
                _excludedNumbersList.add({
                  'id': DateTime.now().millisecondsSinceEpoch,
                  'contactName': name.isEmpty ? 'Excluded Contact' : name,
                  'contactNumber': phone,
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Phone number added to exclusion list.'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Number'),
          ),
        ],
      ),
    );
  }

  void _showImportExcludeNumbersDialog(BuildContext context) {
    final bulkCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: Color(0xFFF97316)),
            SizedBox(width: 8),
            Text('Import Exclude Phone Numbers', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter phone numbers to exclude (one per line, format: "Name, Number" or just "Number").',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bulkCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'CEO Personal, +91 99999 00001\nTesting Device, +91 98888 11112\n+91 97777 22223',
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
              final raw = bulkCtrl.text.trim();
              if (raw.isNotEmpty) {
                final lines = raw.split('\n');
                int count = 0;
                setState(() {
                  for (final line in lines) {
                    final trimmed = line.trim();
                    if (trimmed.isEmpty) continue;
                    if (trimmed.contains(',')) {
                      final parts = trimmed.split(',');
                      _excludedNumbersList.add({
                        'id': DateTime.now().millisecondsSinceEpoch + count,
                        'contactName': parts[0].trim(),
                        'contactNumber': parts.sublist(1).join(',').trim(),
                      });
                    } else {
                      _excludedNumbersList.add({
                        'id': DateTime.now().millisecondsSinceEpoch + count,
                        'contactName': 'Bulk Excluded',
                        'contactNumber': trimmed,
                      });
                    }
                    count++;
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count numbers imported into exclusion list.'),
                    backgroundColor: const Color(0xFF10B981),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Import Now'),
          ),
        ],
      ),
    );
  }

  void _showEditExcludeNumberDialog(Map<String, dynamic> item) {
    final nameCtrl = TextEditingController(text: item['contactName']);
    final numberCtrl = TextEditingController(text: item['contactNumber']);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Edit Excluded Number', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: numberCtrl,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
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
              setState(() {
                item['contactName'] = nameCtrl.text.trim();
                item['contactNumber'] = numberCtrl.text.trim();
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF97316),
              foregroundColor: Colors.white,
            ),
            child: const Text('Update'),
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
