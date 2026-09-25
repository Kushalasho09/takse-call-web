// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

class LeadsDataTableView extends StatefulWidget {
  final List<LeadItem> leads;
  final VoidCallback onAddLead;
  final VoidCallback onImportLeads;
  final VoidCallback onToggleEmptyState;
  final Function(LeadItem lead) onLeadUpdated;
  final Function(String leadId) onLeadDeleted;
  final Function(List<String> leadIds, String newAssignee, String newAssigneePhone)? onBulkReassign;
  final Function(List<String> leadIds, bool trash)? onBulkTrash;

  const LeadsDataTableView({
    super.key,
    required this.leads,
    required this.onAddLead,
    required this.onImportLeads,
    required this.onToggleEmptyState,
    required this.onLeadUpdated,
    required this.onLeadDeleted,
    this.onBulkReassign,
    this.onBulkTrash,
  });

  @override
  State<LeadsDataTableView> createState() => _LeadsDataTableViewState();
}

class _LeadsDataTableViewState extends State<LeadsDataTableView> {
  String _activeTab = 'assigned'; // 'assigned' or 'trashed'

  // Advanced Filter state
  bool _showAdvancedFilter = false;
  String _contactStateFilter = 'all'; // 'all', 'contacted', 'never_contacted'
  String? _advancedStatusFilter;
  String? _advancedEmployeeFilter;
  String? _advancedTagFilter;

  // Inline table search controllers
  final TextEditingController _searchNameCtrl = TextEditingController();
  final TextEditingController _searchPhoneCtrl = TextEditingController();
  final TextEditingController _searchEmployeeCtrl = TextEditingController();
  String? _selectedTagFilter;
  String? _selectedStatusFilter;
  String? _selectedAssigneeFilter;
  String? _selectedCallTypeFilter;
  String _pageSize = '50';

  bool _selectAll = false;

  final List<String> _employeeRoster = [
    'kushal asodia (+91-9664579043)',
    'Rohan Sharma (+91-9876543210)',
    'Amit Patel (+91-9822334455)',
    'Priya Verma (+91-9712345678)',
  ];

  @override
  void dispose() {
    _searchNameCtrl.dispose();
    _searchPhoneCtrl.dispose();
    _searchEmployeeCtrl.dispose();
    super.dispose();
  }

  List<LeadItem> get _selectedLeads {
    return _filteredLeads.where((l) => l.isSelected).toList();
  }

  List<LeadItem> get _filteredLeads {
    return widget.leads.where((item) {
      if (_activeTab == 'assigned' && item.isTrashed) return false;
      if (_activeTab == 'trashed' && !item.isTrashed) return false;

      // Contact State filter from Advanced Filter
      if (_contactStateFilter == 'contacted' && item.attempts == 0) return false;
      if (_contactStateFilter == 'never_contacted' && item.attempts > 0) return false;

      if (_advancedStatusFilter != null && item.status != _advancedStatusFilter) return false;
      if (_advancedEmployeeFilter != null && !item.assignedTo.contains(_advancedEmployeeFilter!)) return false;
      if (_advancedTagFilter != null && !item.tags.contains(_advancedTagFilter!)) return false;

      // Inline Filters
      if (_searchNameCtrl.text.isNotEmpty &&
          !item.name.toLowerCase().contains(_searchNameCtrl.text.toLowerCase())) {
        return false;
      }
      if (_searchPhoneCtrl.text.isNotEmpty &&
          !item.phone.toLowerCase().contains(_searchPhoneCtrl.text.toLowerCase())) {
        return false;
      }
      if (_searchEmployeeCtrl.text.isNotEmpty &&
          !(item.lastCallEmployee ?? '').toLowerCase().contains(_searchEmployeeCtrl.text.toLowerCase())) {
        return false;
      }
      if (_selectedTagFilter != null && !item.tags.contains(_selectedTagFilter)) {
        return false;
      }
      if (_selectedStatusFilter != null && item.status != _selectedStatusFilter) {
        return false;
      }
      if (_selectedAssigneeFilter != null && item.assignedTo != _selectedAssigneeFilter) {
        return false;
      }
      if (_selectedCallTypeFilter != null && item.lastCallType != _selectedCallTypeFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  void _showExportMenu(BuildContext context, TapDownDetails details) {
    final messenger = ScaffoldMessenger.of(context);
    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx - 120,
        details.globalPosition.dy + 10,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      items: const [
        PopupMenuItem(
          value: 'csv',
          child: Row(
            children: [
              Icon(Icons.table_chart_outlined, size: 16, color: Color(0xFF1E293B)),
              SizedBox(width: 8),
              Text('Export to CSV', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'excel',
          child: Row(
            children: [
              Icon(Icons.file_present_outlined, size: 16, color: Color(0xFF1E293B)),
              SizedBox(width: 8),
              Text('Export to Excel (.xlsx)', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'pdf',
          child: Row(
            children: [
              Icon(Icons.picture_as_pdf_outlined, size: 16, color: Color(0xFF1E293B)),
              SizedBox(width: 8),
              Text('Export to PDF', style: TextStyle(fontSize: 13)),
            ],
          ),
        ),
      ],
    ).then((val) {
      if (val != null) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Leads exported successfully as ${val.toString().toUpperCase()}.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    });
  }

  // Bulk Reassign Modal
  void _showBulkReassignDialog() {
    final selected = _selectedLeads;
    if (selected.isEmpty) return;

    String targetEmployee = _employeeRoster.first;
    bool isRoundRobin = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.people_alt_outlined, color: Color(0xFFF59E0B), size: 22),
              const SizedBox(width: 10),
              Text('Bulk Reassign (${selected.length} Leads)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Choose assignment strategy for the selected leads:', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                const SizedBox(height: 16),
                RadioListTile<bool>(
                  title: const Text('Assign to Single Telecaller', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  value: false,
                  groupValue: isRoundRobin,
                  activeColor: const Color(0xFFF59E0B),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDlgState(() => isRoundRobin = val ?? false),
                ),
                if (!isRoundRobin) ...[
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: targetEmployee,
                    isExpanded: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    items: _employeeRoster.map((emp) => DropdownMenuItem(value: emp, child: Text(emp, style: const TextStyle(fontSize: 13)))).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => targetEmployee = val);
                    },
                  ),
                ],
                const SizedBox(height: 8),
                RadioListTile<bool>(
                  title: const Text('Distribute via Round-Robin rotation', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                  subtitle: const Text('Evenly splits leads across all 4 active agents', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  value: true,
                  groupValue: isRoundRobin,
                  activeColor: const Color(0xFFF59E0B),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setDlgState(() => isRoundRobin = val ?? false),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                final selectedIds = selected.map((l) => l.id).toList();
                String name = 'kushal asodia';
                String phone = '+91-9664579043';
                if (!isRoundRobin && targetEmployee.contains('(')) {
                  final parts = targetEmployee.split('(');
                  name = parts[0].trim();
                  phone = parts[1].replaceAll(')', '').trim();
                }

                setState(() {
                  int idx = 0;
                  for (final item in widget.leads) {
                    if (selectedIds.contains(item.id)) {
                      if (isRoundRobin) {
                        final emp = _employeeRoster[idx % _employeeRoster.length];
                        final parts = emp.split('(');
                        item.assignedTo = parts[0].trim();
                        item.assignedToPhone = parts[1].replaceAll(')', '').trim();
                        idx++;
                      } else {
                        item.assignedTo = name;
                        item.assignedToPhone = phone;
                      }
                      item.isSelected = false;
                    }
                  }
                  _selectAll = false;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${selectedIds.length} leads reassigned successfully.'),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Apply Reassignment'),
            ),
          ],
        ),
      ),
    );
  }

  // Bulk Trash / Restore Action
  void _handleBulkTrash({required bool trash}) {
    final selected = _selectedLeads;
    if (selected.isEmpty) return;

    setState(() {
      for (final item in selected) {
        item.isTrashed = trash;
        item.isSelected = false;
      }
      _selectAll = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(trash ? '${selected.length} leads moved to Trash.' : '${selected.length} leads restored to Assigned Leads.'),
        backgroundColor: trash ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Lead Activity History Timeline Modal
  void _showActivityHistoryDialog(LeadItem lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.history_rounded, color: Color(0xFF2563EB), size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Call Activity History: ${lead.name.toUpperCase()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${lead.phone} • Lead #${lead.leadNumber} • ${lead.attempts} Call Attempts', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 580,
          child: lead.activityHistory.isEmpty
              ? Container(
                  padding: const EdgeInsets.all(32),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.phone_missed_outlined, size: 36, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text('No call activities logged for this lead yet.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                      SizedBox(height: 4),
                      Text('Activities are automatically recorded upon telephony completion in the telecaller app.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: lead.activityHistory.map((act) {
                      final isOutgoing = act.callType.toLowerCase() == 'outgoing';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isOutgoing ? Icons.call_made_rounded : Icons.call_missed_rounded,
                                  size: 16,
                                  color: isOutgoing ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${act.callType.toUpperCase()} CALL (${act.durationSeconds}s)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: isOutgoing ? const Color(0xFF047857) : const Color(0xFFB91C1C),
                                  ),
                                ),
                                const Spacer(),
                                Text(act.timestamp, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text('Dialed By: ${act.callerName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                                  child: Text('Status: ${act.newStatus}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Note: ${act.notes}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
                            if (act.reminderDate != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.alarm_on_rounded, size: 13, color: Color(0xFFD97706)),
                                  const SizedBox(width: 4),
                                  Text('Reminder Scheduled: ${act.reminderDate}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // Edit Lead Modal
  void _showEditLeadDialog(LeadItem lead) {
    final nameCtrl = TextEditingController(text: lead.name);
    final phoneCtrl = TextEditingController(text: lead.phone.replaceAll('+91 ', ''));
    final companyCtrl = TextEditingController(text: lead.company ?? '');
    String status = lead.status;
    String assignee = lead.assignedTo;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Edit Lead Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Lead Name', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                  const SizedBox(height: 12),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number', prefixText: '+91 ', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                  const SizedBox(height: 12),
                  TextField(controller: companyCtrl, decoration: const InputDecoration(labelText: 'Company Name', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: status,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Lead Status', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: ['New Inflow', 'Positive', 'Follow Up', 'Contacted', 'Closed - Won', 'Closed - Lost'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (val) {
                      if (val != null) setDlgState(() => status = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _employeeRoster.any((e) => e.contains(assignee)) ? _employeeRoster.firstWhere((e) => e.contains(assignee)) : _employeeRoster.first,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Assign To Employee', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                    items: _employeeRoster.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12.5)))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDlgState(() => assignee = val.split('(')[0].trim());
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final updated = lead.copyWith(
                  name: nameCtrl.text.trim(),
                  phone: '+91 ${phoneCtrl.text.trim()}',
                  company: companyCtrl.text.trim().isNotEmpty ? companyCtrl.text.trim() : null,
                  status: status,
                  assignedTo: assignee,
                );
                widget.onLeadUpdated(updated);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead details updated successfully.')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeadDetailsDialog(LeadItem lead) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFFEF3C7),
              child: Icon(Icons.person, color: Color(0xFFF59E0B)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lead.name.toUpperCase(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('${lead.phone} • Lead #${lead.leadNumber}', style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              ],
            ),
          ],
        ),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailTile('Company', lead.company ?? 'N/A'),
                _detailTile('Email', lead.email ?? 'N/A'),
                _detailTile('Status', lead.status),
                if (lead.reminderDate != null) _detailTile('Reminder Date', lead.reminderDate!),
                _detailTile('Assigned To', '${lead.assignedTo} (${lead.assignedToPhone})'),
                _detailTile('Created Date', lead.createdDate),
                _detailTile('Call Attempts', '${lead.attempts} dials'),
                _detailTile('Last Call', '${lead.lastCallTime} (${lead.lastCallDuration ?? '-'})'),
                _detailTile('Last Summary', lead.lastCallSummary ?? 'N/A'),
                _detailTile('Tags', lead.tags.join(', ')),
                if (lead.price != null) _detailTile('Price / Value', lead.price!),
                if (lead.customFormData.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  const Text('Custom Dynamic Form Data:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  ...lead.customFormData.entries.map((e) => _detailTile(e.key.replaceAll('_', ' ').toUpperCase(), e.value.toString())),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showActivityHistoryDialog(lead);
            },
            child: const Text('View Call Logs'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leadsToShow = _filteredLeads;
    final selectedCount = _selectedLeads.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Card Header with "My Leads" & "EXPORT v"
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                const Text(
                  'My Leads',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const Spacer(),
                GestureDetector(
                  onTapDown: (details) => _showExportMenu(context, details),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.download_rounded, size: 16, color: Color(0xFF1E293B)),
                        SizedBox(width: 6),
                        Text('EXPORT', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 2. Subheader Bar with Tabs & Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                // Left Tabs: Assigned Leads & Trashed Leads
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSubTab(
                      title: 'Assigned Leads',
                      icon: Icons.person_add_alt_1_outlined,
                      isActive: _activeTab == 'assigned',
                      onTap: () => setState(() => _activeTab = 'assigned'),
                    ),
                    const SizedBox(width: 24),
                    _buildSubTab(
                      title: 'Trashed Leads',
                      icon: Icons.delete_outline_rounded,
                      isActive: _activeTab == 'trashed',
                      onTap: () => setState(() => _activeTab = 'trashed'),
                    ),
                  ],
                ),

                // Right Toolbar Controls
                Wrap(
                  spacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    // ADVANCED FILTER Toggle
                    InkWell(
                      onTap: () => setState(() => _showAdvancedFilter = !_showAdvancedFilter),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: _showAdvancedFilter ? const Color(0xFFEFF6FF) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.filter_alt_outlined, size: 16, color: _showAdvancedFilter ? const Color(0xFF2563EB) : const Color(0xFF1E293B)),
                            const SizedBox(width: 4),
                            Text(
                              'ADVANCED FILTER',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: _showAdvancedFilter ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(width: 2),
                            Icon(
                              _showAdvancedFilter ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                              size: 16,
                              color: const Color(0xFF64748B),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16, child: VerticalDivider(color: Color(0xFFCBD5E1), width: 16)),

                    // Add Lead Button
                    OutlinedButton.icon(
                      onPressed: widget.onAddLead,
                      icon: const Icon(Icons.person_add_alt_1_rounded, size: 15, color: Color(0xFFF59E0B)),
                      label: const Text('Add Lead', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Import Leads Button
                    OutlinedButton.icon(
                      onPressed: widget.onImportLeads,
                      icon: const Icon(Icons.download_rounded, size: 15, color: Color(0xFFF59E0B)),
                      label: const Text('Import Leads', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFF59E0B)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),

                    // Show entries dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _pageSize,
                          isDense: true,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF1E293B)),
                          items: ['5', '10', '25', '50', '100'].map((val) => DropdownMenuItem(value: val, child: Text('Show $val'))).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _pageSize = val);
                          },
                        ),
                      ),
                    ),

                    // Quick Toggle for Empty State Preview
                    Tooltip(
                      message: 'Preview Welcome Empty State',
                      child: InkWell(
                        onTap: widget.onToggleEmptyState,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.visibility_outlined, size: 14, color: Color(0xFFB45309)),
                              SizedBox(width: 4),
                              Text('Empty State View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Advanced Filter Accordion Drawer
          if (_showAdvancedFilter) _buildAdvancedFilterAccordion(),

          // Bulk Actions Floating Toolbar (When leads are selected)
          if (selectedCount > 0) _buildBulkActionBar(selectedCount),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 3. Multi-column Data Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: 2620,
              child: Column(
                children: [
                  _buildHeaderRow(),
                  _buildFilterRow(),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                  if (leadsToShow.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(Icons.folder_open_rounded, size: 40, color: Color(0xFFCBD5E1)),
                          SizedBox(height: 8),
                          Text('No leads found matching your criteria.', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  else
                    ...leadsToShow.map((lead) => _buildDataRow(lead)),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 4. Footer Pagination Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Text(
                  'Showing 1-${leadsToShow.length} of ${leadsToShow.length} records',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.first_page_rounded, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), color: const Color(0xFF94A3B8), onPressed: null),
                    IconButton(icon: const Icon(Icons.chevron_left_rounded, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), color: const Color(0xFF94A3B8), onPressed: null),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('1', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B))),
                    ),
                    IconButton(icon: const Icon(Icons.chevron_right_rounded, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), color: const Color(0xFF94A3B8), onPressed: null),
                    IconButton(icon: const Icon(Icons.last_page_rounded, size: 18), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 28, minHeight: 28), color: const Color(0xFF94A3B8), onPressed: null),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Bulk Actions Bar
  Widget _buildBulkActionBar(int count) {
    return Container(
      color: const Color(0xFFFEF3C7),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(4)),
            child: Text('$count Selected', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: _showBulkReassignDialog,
            icon: const Icon(Icons.swap_horiz_rounded, size: 15),
            label: const Text('Bulk Reassign'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E293B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
          ),
          const SizedBox(width: 8),
          if (_activeTab == 'assigned')
            ElevatedButton.icon(
              onPressed: () => _handleBulkTrash(trash: true),
              icon: const Icon(Icons.delete_outline_rounded, size: 15),
              label: const Text('Move to Trash'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            )
          else
            ElevatedButton.icon(
              onPressed: () => _handleBulkTrash(trash: false),
              icon: const Icon(Icons.restore_from_trash_rounded, size: 15),
              label: const Text('Restore Leads'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            ),
          const Spacer(),
          TextButton(
            onPressed: () {
              setState(() {
                for (final item in widget.leads) {
                  item.isSelected = false;
                }
                _selectAll = false;
              });
            },
            child: const Text('Clear Selection', style: TextStyle(fontSize: 12, color: Color(0xFFB45309))),
          ),
        ],
      ),
    );
  }

  // Advanced Filter Accordion View
  Widget _buildAdvancedFilterAccordion() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.tune_rounded, size: 16, color: Color(0xFF1E293B)),
              SizedBox(width: 8),
              Text('Advanced Filter Pipeline', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              // Contact State Toggle
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Contact State', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _filterChipButton('All', _contactStateFilter == 'all', () => setState(() => _contactStateFilter = 'all')),
                        const SizedBox(width: 6),
                        _filterChipButton('Contacted', _contactStateFilter == 'contacted', () => setState(() => _contactStateFilter = 'contacted')),
                        const SizedBox(width: 6),
                        _filterChipButton('Never Dialed', _contactStateFilter == 'never_contacted', () => setState(() => _contactStateFilter = 'never_contacted')),
                      ],
                    ),
                  ],
                ),
              ),
              // Status filter
              SizedBox(
                width: 200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lead Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    _tableDropdown(
                      value: _advancedStatusFilter,
                      hint: 'All Statuses',
                      items: ['Positive', 'Follow Up', 'Contacted', 'New Inflow', 'Closed - Won', 'Closed - Lost'],
                      onChanged: (val) => setState(() => _advancedStatusFilter = val),
                    ),
                  ],
                ),
              ),
              // Employee filter
              SizedBox(
                width: 220,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assigned Telecaller', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    _tableDropdown(
                      value: _advancedEmployeeFilter,
                      hint: 'All Agents',
                      items: ['kushal asodia', 'Rohan Sharma', 'Amit Patel'],
                      onChanged: (val) => setState(() => _advancedEmployeeFilter = val),
                    ),
                  ],
                ),
              ),
              // Tag filter
              SizedBox(
                width: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lead Tag', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                    const SizedBox(height: 6),
                    _tableDropdown(
                      value: _advancedTagFilter,
                      hint: 'All Tags',
                      items: ['Hot Lead', 'Urgent', 'Instagram', 'Google Sheet', 'New'],
                      onChanged: (val) => setState(() => _advancedTagFilter = val),
                    ),
                  ],
                ),
              ),
              // Reset button
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: TextButton.icon(
                  onPressed: () {
                    setState(() {
                      _contactStateFilter = 'all';
                      _advancedStatusFilter = null;
                      _advancedEmployeeFilter = null;
                      _advancedTagFilter = null;
                    });
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 14),
                  label: const Text('Reset All', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChipButton(String title, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: selected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1)),
        ),
        child: Text(
          title,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: selected ? Colors.white : const Color(0xFF475569)),
        ),
      ),
    );
  }

  Widget _buildSubTab({required String title, required IconData icon, required bool isActive, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFFF59E0B) : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF64748B)),
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontSize: 13.5, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFFF59E0B) : const Color(0xFF64748B))),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Container(
      color: const Color(0xFFF8FAFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Checkbox(
              value: _selectAll,
              activeColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              onChanged: (val) {
                setState(() {
                  _selectAll = val ?? false;
                  for (final item in widget.leads) {
                    item.isSelected = _selectAll;
                  }
                });
              },
            ),
          ),
          _headerCell('Sr.No', width: 60),
          _headerCell('Lead Name', width: 170, hasSort: true, hasMenu: true),
          _headerCell('Contact Number', width: 170, hasSort: true, hasMenu: true),
          _headerCell('Created Date', width: 180, hasSort: true, hasMenu: true),
          _headerCell('Modified Date', width: 170, hasSort: true, hasMenu: true),
          _headerCell('No of Attempts', width: 130, hasInfo: true, hasMenu: true),
          _headerCell('Lead Tags', width: 150, hasMenu: true),
          _headerCell('Tag Assigned Dates', width: 160, hasMenu: true),
          _headerCell('Assign To', width: 220),
          _headerCell('Lead Status', width: 140, hasMenu: true),
          _headerCell('Reminder Date', width: 170, hasMenu: true),
          _headerCell('Last Call - Employee', width: 170, hasMenu: true),
          _headerCell('Last Call - Call Type', width: 150, hasMenu: true),
          _headerCell('Last Call - Call Time', width: 180, hasMenu: true),
          _headerCell('Last Call - Summary', width: 190, hasMenu: true),
          _headerCell('Action', width: 100),
        ],
      ),
    );
  }

  Widget _headerCell(String label, {required double width, bool hasSort = false, bool hasMenu = false, bool hasInfo = false}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)), overflow: TextOverflow.ellipsis),
            ),
            if (hasInfo) ...[
              const SizedBox(width: 4),
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFFF59E0B)),
            ],
            if (hasSort) ...[
              const SizedBox(width: 4),
              const Icon(Icons.unfold_more_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
            if (hasMenu) ...[
              const SizedBox(width: 4),
              const Icon(Icons.more_vert_rounded, size: 14, color: Color(0xFFCBD5E1)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const SizedBox(width: 60),
          SizedBox(width: 170, child: _tableSearchInput(controller: _searchNameCtrl, hint: 'Search', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          SizedBox(width: 160, child: _tableSearchInput(controller: _searchPhoneCtrl, hint: 'Search', onChanged: (_) => setState(() {}))),
          const SizedBox(width: 10),
          SizedBox(width: 170, child: _tableDateRangeInput('Select Date Range')),
          const SizedBox(width: 10),
          SizedBox(width: 160, child: _tableDateRangeInput('Select Date Range')),
          const SizedBox(width: 130),
          SizedBox(width: 150, child: _tableDropdown(value: _selectedTagFilter, hint: 'Select...', items: ['New', 'Hot Lead', 'Urgent', 'Instagram'], onChanged: (val) => setState(() => _selectedTagFilter = val))),
          const SizedBox(width: 160),
          SizedBox(width: 220, child: _tableDropdown(value: _selectedAssigneeFilter, hint: 'Select...', items: ['kushal asodia', 'Rohan Sharma', 'Amit Patel'], onChanged: (val) => setState(() => _selectedAssigneeFilter = val))),
          SizedBox(width: 140, child: _tableDropdown(value: _selectedStatusFilter, hint: 'Select...', items: ['Positive', 'Follow Up', 'Contacted', 'New Inflow'], onChanged: (val) => setState(() => _selectedStatusFilter = val))),
          const SizedBox(width: 170), // Reminder date filter spacing
          SizedBox(width: 170, child: _tableSearchInput(controller: _searchEmployeeCtrl, hint: 'Search', onChanged: (_) => setState(() {}))),
          SizedBox(width: 150, child: _tableDropdown(value: _selectedCallTypeFilter, hint: 'Select...', items: ['Outgoing', 'Incoming', 'Missed'], onChanged: (val) => setState(() => _selectedCallTypeFilter = val))),
          SizedBox(width: 180, child: _tableDateRangeInput('Select Date')),
          const SizedBox(width: 190), // Summary
          const SizedBox(width: 100), // Action
        ],
      ),
    );
  }

  Widget _tableSearchInput({required TextEditingController controller, required String hint, required ValueChanged<String> onChanged}) {
    return SizedBox(
      height: 32,
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(fontSize: 12),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          suffixIcon: const Icon(Icons.search_rounded, size: 14, color: Color(0xFF64748B)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFCBD5E1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), borderSide: const BorderSide(color: Color(0xFFF59E0B))),
        ),
      ),
    );
  }

  Widget _tableDateRangeInput(String hint) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(hint, style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)), overflow: TextOverflow.ellipsis)),
          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
        ],
      ),
    );
  }

  Widget _tableDropdown({required String? value, required String hint, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          hint: Text(hint, style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8))),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Color(0xFF64748B)),
          items: [
            const DropdownMenuItem<String>(value: null, child: Text('All', style: TextStyle(fontSize: 12))),
            ...items.map((it) => DropdownMenuItem<String>(value: it, child: Text(it, style: const TextStyle(fontSize: 12)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDataRow(LeadItem lead) {
    Color statusColor = const Color(0xFF3B82F6);
    if (lead.status == 'Positive' || lead.status == 'Closed - Won') statusColor = const Color(0xFF10B981);
    if (lead.status == 'Follow Up') statusColor = const Color(0xFFF59E0B);
    if (lead.status == 'Closed - Lost') statusColor = const Color(0xFFEF4444);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Checkbox
          SizedBox(
            width: 40,
            child: Checkbox(
              value: lead.isSelected,
              activeColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
              onChanged: (val) {
                setState(() => lead.isSelected = val ?? false);
              },
            ),
          ),
          // Sr.No
          SizedBox(width: 60, child: Text('${lead.srNo}', style: const TextStyle(fontSize: 13, color: Color(0xFF334155)))),
          // Lead Name & Badge
          SizedBox(
            width: 170,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: InkWell(
                      onTap: () => _showLeadDetailsDialog(lead),
                      child: Text(
                        lead.name,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B), decoration: TextDecoration.underline, decorationColor: Color(0xFFF59E0B)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                    child: Text('#${lead.leadNumber}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
          // Contact Number
          SizedBox(width: 170, child: Text(lead.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)))),
          // Created Date
          SizedBox(width: 180, child: Text(lead.createdDate, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)))),
          // Modified Date
          SizedBox(width: 170, child: Text(lead.modifiedDate ?? '-', style: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)))),
          // No of Attempts
          SizedBox(
            width: 130,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 11,
                  backgroundColor: lead.attempts > 0 ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                  child: Text('${lead.attempts}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: lead.attempts > 0 ? const Color(0xFF2563EB) : const Color(0xFF94A3B8))),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    lead.attempts == 0 ? 'Never dialed' : '${lead.attempts} dials',
                    style: TextStyle(fontSize: 11.5, color: lead.attempts == 0 ? const Color(0xFFEF4444) : const Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          // Lead Tags
          SizedBox(
            width: 150,
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: lead.tags.map((t) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Text(t, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
                );
              }).toList(),
            ),
          ),
          // Tag Assigned Dates
          SizedBox(width: 160, child: Text(lead.tagAssignedDate, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)))),
          // Assign To
          SizedBox(
            width: 220,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(lead.assignedTo, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                Text('(${lead.assignedToPhone})', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Flexible(child: Text(lead.assignedDate, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ],
            ),
          ),
          // Lead Status Badge
          SizedBox(
            width: 140,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                child: Text(lead.status, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: statusColor)),
              ),
            ),
          ),
          // Reminder Date
          SizedBox(
            width: 170,
            child: lead.reminderDate != null
                ? Row(
                    children: [
                      const Icon(Icons.alarm_on_rounded, size: 14, color: Color(0xFFD97706)),
                      const SizedBox(width: 4),
                      Flexible(child: Text(lead.reminderDate!, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFB45309)), overflow: TextOverflow.ellipsis)),
                    ],
                  )
                : const Text('-', style: TextStyle(fontSize: 12, color: Color(0xFFCBD5E1))),
          ),
          // Last Call - Employee
          SizedBox(width: 170, child: Text(lead.lastCallEmployee ?? '-', style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)))),
          // Last Call - Call Type
          SizedBox(width: 150, child: Text(lead.lastCallType, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)))),
          // Last Call - Call Time
          SizedBox(width: 180, child: Text(lead.lastCallTime, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B)))),
          // Last Call - Summary
          SizedBox(
            width: 190,
            child: Text(lead.lastCallSummary ?? '-', style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569)), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          // Action Column
          SizedBox(
            width: 100,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.history_rounded, size: 16, color: Color(0xFF2563EB)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  tooltip: 'View Call Logs',
                  onPressed: () => _showActivityHistoryDialog(lead),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF94A3B8)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  onSelected: (val) {
                    if (val == 'details') {
                      _showLeadDetailsDialog(lead);
                    } else if (val == 'edit') {
                      _showEditLeadDialog(lead);
                    } else if (val == 'trash') {
                      setState(() => lead.isTrashed = !lead.isTrashed);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(lead.isTrashed ? 'Lead moved to trash.' : 'Lead restored.')),
                      );
                    } else if (val == 'delete') {
                      widget.onLeadDeleted(lead.id);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead permanently deleted.')));
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'details',
                      child: Row(children: [Icon(Icons.visibility_outlined, size: 16), SizedBox(width: 8), Text('View Details', style: TextStyle(fontSize: 12.5))]),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [Icon(Icons.edit_outlined, size: 16), SizedBox(width: 8), Text('Edit Lead', style: TextStyle(fontSize: 12.5))]),
                    ),
                    PopupMenuItem(
                      value: 'trash',
                      child: Row(
                        children: [
                          Icon(lead.isTrashed ? Icons.restore_from_trash_outlined : Icons.delete_outline_rounded, size: 16, color: lead.isTrashed ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                          const SizedBox(width: 8),
                          Text(lead.isTrashed ? 'Restore' : 'Move to Trash', style: TextStyle(fontSize: 12.5, color: lead.isTrashed ? const Color(0xFF10B981) : const Color(0xFFEF4444))),
                        ],
                      ),
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
}
