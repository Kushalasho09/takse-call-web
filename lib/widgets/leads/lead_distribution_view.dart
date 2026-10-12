import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/lead_item.dart';
import '../../services/firestore_sync_service.dart';
import '../../services/web_auth_service.dart';
import '../../services/web_lead_firestore_service.dart';
import '../../theme/app_colors.dart';

class LeadDistributionView extends StatefulWidget {
  final List<LeadItem> leads;
  final VoidCallback? onRefresh;

  const LeadDistributionView({
    super.key,
    required this.leads,
    this.onRefresh,
  });

  @override
  State<LeadDistributionView> createState() => _LeadDistributionViewState();
}

class _LeadDistributionViewState extends State<LeadDistributionView> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _viewMode = 'table'; // 'table' or 'tree'
  String _activeCompartment = 'pending'; // 'pending', 'sent', 'all'
  String _selectedEmployeeFilter = 'all';
  String _selectedTimeSlot = 'all'; // 'all', 'today', 'morning', 'afternoon', 'evening'
  int _currentPage = 0;
  static const int _pageSize = 15;
  final Set<String> _selectedLeadIds = {};

  static const List<Color> _chartColors = [
    Color(0xFF38BDF8),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFA855F7),
    Color(0xFFEC4899),
    Color(0xFF06B6D4),
    Color(0xFFF97316),
    Color(0xFF6366F1),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _getEmployeeColor(int index) {
    return _chartColors[index % _chartColors.length];
  }

  bool _isPendingLead(LeadItem l) {
    return l.assignedTo.isEmpty ||
        l.assignedTo == '-' ||
        l.assignedTo == 'Unassigned' ||
        l.status.trim().toLowerCase() == 'pending';
  }

  // Time slot matching helper
  bool _matchesTimeSlot(LeadItem lead) {
    if (_selectedTimeSlot == 'all') return true;
    final dt = lead.effectiveCreatedAt;
    final now = DateTime.now();

    if (_selectedTimeSlot == 'today') {
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    } else if (_selectedTimeSlot == 'morning') {
      // 6:00 AM to 12:00 PM
      return dt.hour >= 6 && dt.hour < 12;
    } else if (_selectedTimeSlot == 'afternoon') {
      // 12:00 PM to 6:00 PM
      return dt.hour >= 12 && dt.hour < 18;
    } else if (_selectedTimeSlot == 'evening') {
      // 6:00 PM to Midnight
      return dt.hour >= 18 || dt.hour < 6;
    }
    return true;
  }

  // ==========================================
  // 1. AUTO DISTRIBUTE DIALOG (Equal Quota)
  // ==========================================
  void _showAutoDistributeDialog(BuildContext context, List<LeadItem> pendingLeads, List<FirestoreDevice> employees) {
    if (pendingLeads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aapki organization ki sabhi leads already assign ho chuki hain! Koi pending lead nahi hai.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aapki organization me koi active employee nahi mila. Pehle Manage > Employees me employee register karein.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final selectedEmployeeIds = Set<String>.from(employees.map((e) => e.connectCode));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final activeTargetEmployees = employees.where((e) => selectedEmployeeIds.contains(e.connectCode)).toList();
          final leadsCount = pendingLeads.length;
          final empCount = activeTargetEmployees.length;

          final basePerEmp = empCount > 0 ? (leadsCount / empCount).floor() : 0;
          final remainder = empCount > 0 ? (leadsCount % empCount) : 0;

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shuffle_rounded, color: Color(0xFF10B981), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Automatic Lead Distribution',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Divide $leadsCount pending leads equally across your active employees',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'DISTRIBUTION BREAKDOWN',
                                style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: const Color(0xFF10B981), letterSpacing: 1.0),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '$leadsCount Pending Leads',
                                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Selected Employees', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text('$empCount Employees', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                                  ],
                                ),
                              ),
                              Container(width: 1, height: 32, color: const Color(0xFF334155)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Base Quota', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                    const SizedBox(height: 2),
                                    Text('$basePerEmp leads / emp', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
                                  ],
                                ),
                              ),
                              if (remainder > 0) ...[
                                Container(width: 1, height: 32, color: const Color(0xFF334155)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Remainder (+1)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                                      const SizedBox(height: 2),
                                      Text('$remainder get ${basePerEmp + 1}', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            empCount > 0
                                ? 'Sabhi employees ko barabar leads milengi ($basePerEmp-each) aur status SENT ho jayega. Bachi hui $remainder leads pehle $remainder employees ko assign ho jayengi.'
                                : 'Please select at least one employee.',
                            style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8), height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Select Employees in Distribution:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: employees.length,
                        itemBuilder: (c, idx) {
                          final emp = employees[idx];
                          final isChecked = selectedEmployeeIds.contains(emp.connectCode);
                          return CheckboxListTile(
                            dense: true,
                            value: isChecked,
                            activeColor: const Color(0xFF10B981),
                            title: Text(emp.userName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            subtitle: Text(emp.userPhone, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
                            onChanged: (bool? val) {
                              setModalState(() {
                                if (val == true) {
                                  selectedEmployeeIds.add(emp.connectCode);
                                } else {
                                  selectedEmployeeIds.remove(emp.connectCode);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: activeTargetEmployees.isEmpty
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final leadIdsToDistribute = pendingLeads.map((l) => l.id).toList();
                        final count = await WebLeadFirestoreService.autoDistributeLeads(
                          leadIds: leadIdsToDistribute,
                          employees: activeTargetEmployees,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 $count leads marked as SENT and distributed across ${activeTargetEmployees.length} employees!'),
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          widget.onRefresh?.call();
                        }
                      },
                icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                label: Text('Distribute $leadsCount Leads Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 2. MANUAL QUOTAS DIALOG (Custom Counts per Employee)
  // ==========================================
  void _showManualQuotasDialog(BuildContext context, List<LeadItem> pendingLeads, List<FirestoreDevice> employees) {
    if (pendingLeads.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pending leads available to allocate.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No employees found. Please register employees first.'), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    final Map<String, int> quotas = {for (final e in employees) e.userPhone: 0};
    final Map<String, TextEditingController> controllers = {
      for (final e in employees) e.userPhone: TextEditingController(text: '0'),
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final totalPending = pendingLeads.length;
          final totalAllocated = quotas.values.fold(0, (sum, v) => sum + v);
          final remaining = totalPending - totalAllocated;
          final isOverAllocated = remaining < 0;

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.edit_note_rounded, color: Color(0xFFF59E0B), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manual Quota Allocation to Employees',
                        style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textPrimary),
                      ),
                      Text(
                        'Set custom lead counts per telecaller (e.g. Agent 1: 10, Agent 2: 5, Agent 3: 15)',
                        style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isOverAllocated
                              ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                              : const Color(0xFF10B981).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('PENDING LEADS', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text('$totalPending Fresh', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: const Color(0xFF334155)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ALLOCATED', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text('$totalAllocated Leads', style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFF38BDF8))),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 30, color: const Color(0xFF334155)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('REMAINING', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                                const SizedBox(height: 2),
                                Text(
                                  '$remaining',
                                  style: GoogleFonts.outfit(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isOverAllocated ? const Color(0xFFEF4444) : (remaining == 0 ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('Enter lead count for each Employee:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    const SizedBox(height: 10),

                    ...employees.map((emp) {
                      final current = quotas[emp.userPhone] ?? 0;
                      final ctrl = controllers[emp.userPhone]!;
                      final existingCount = widget.leads.where((l) => l.assignedTo == emp.userName || l.assignedToPhone == emp.userPhone).length;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: current > 0 ? const Color(0xFF38BDF8) : AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                              child: Text(
                                emp.userName.isNotEmpty ? emp.userName[0].toUpperCase() : 'A',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primary),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(emp.userName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                                  Text('${emp.userPhone} • Current: $existingCount leads', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline_rounded, size: 20),
                              color: AppColors.textSecondary,
                              onPressed: () {
                                if (current > 0) {
                                  setModalState(() {
                                    quotas[emp.userPhone] = current - 1;
                                    ctrl.text = '${current - 1}';
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 55,
                              child: TextField(
                                controller: ctrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.jetBrainsMono(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                decoration: InputDecoration(
                                  isDense: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                                  filled: true,
                                  fillColor: AppColors.cardBackground,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.border)),
                                ),
                                onChanged: (val) {
                                  final num = int.tryParse(val) ?? 0;
                                  setModalState(() {
                                    quotas[emp.userPhone] = max(0, num);
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                              color: const Color(0xFF10B981),
                              onPressed: () {
                                if (remaining > 0) {
                                  setModalState(() {
                                    quotas[emp.userPhone] = current + 1;
                                    ctrl.text = '${current + 1}';
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                onPressed: (totalAllocated <= 0 || isOverAllocated)
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final pendingIds = pendingLeads.map((l) => l.id).toList();
                        final count = await WebLeadFirestoreService.distributeCustomQuotas(
                          pendingLeadIds: pendingIds,
                          employeeQuotas: quotas,
                          employees: employees,
                        );
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('🎉 $count leads marked as SENT and allocated across employees!'),
                              backgroundColor: const Color(0xFF059669),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                          widget.onRefresh?.call();
                        }
                      },
                icon: const Icon(Icons.send_rounded, size: 16),
                label: Text('Confirm Quotas ($totalAllocated Leads)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 3. BULK ASSIGN SELECTED LEADS
  // ==========================================
  void _showBulkAssignDialog(BuildContext context, List<FirestoreDevice> employees) {
    if (_selectedLeadIds.isEmpty) return;
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No employees found to assign.')));
      return;
    }

    String selectedEmployeePhone = employees.first.userPhone;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedEmp = employees.firstWhere(
            (e) => e.userPhone == selectedEmployeePhone,
            orElse: () => employees.first,
          );

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.person_add_alt_1_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Manual Assign (${_selectedLeadIds.length} Leads)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      Text('Assign selected leads directly to a telecaller (Status will become Sent)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Choose Employee / Telecaller:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: employees.any((e) => e.userPhone == selectedEmployeePhone) ? selectedEmployeePhone : employees.first.userPhone,
                    dropdownColor: AppColors.cardBackground,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    items: employees.map((e) {
                      return DropdownMenuItem(value: e.userPhone, child: Text('${e.userName} (${e.userPhone})', style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedEmployeePhone = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final count = await WebLeadFirestoreService.bulkAssignLeads(
                    leadIds: _selectedLeadIds.toList(),
                    assignedTo: selectedEmp.userName,
                    assignedToPhone: selectedEmp.userPhone,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('🎉 $count leads marked as SENT and assigned to ${selectedEmp.userName}!'), backgroundColor: const Color(0xFF059669)),
                    );
                    setState(() => _selectedLeadIds.clear());
                    widget.onRefresh?.call();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: Text('Assign ${_selectedLeadIds.length} Leads Now'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // 4. BULK REVOKE SELECTED LEADS
  // ("Lead wapis kheench sakte hain")
  // ==========================================
  void _confirmBulkRevoke(BuildContext context) {
    if (_selectedLeadIds.isEmpty) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFEF4444).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.undo_rounded, color: Color(0xFFEF4444), size: 20),
            ),
            const SizedBox(width: 12),
            Text('Revoke Leads to Pending Pool', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
          ],
        ),
        content: Text(
          'Kya aap ${_selectedLeadIds.length} leads ko employees se wapis kheench kar Pending pool me daalna chahte hain?',
          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final count = await WebLeadFirestoreService.bulkUnassignLeads(_selectedLeadIds.toList());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('✅ $count leads revoked and returned to Pending pool!'), backgroundColor: const Color(0xFF059669)),
                );
                setState(() => _selectedLeadIds.clear());
                widget.onRefresh?.call();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
            child: const Text('Revoke Leads Now'),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 5. SINGLE LEAD ASSIGN / REASSIGN MODAL
  // ==========================================
  void _showSingleAssignDialog(BuildContext context, LeadItem lead, List<FirestoreDevice> employees) {
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No employees found to assign.')));
      return;
    }

    String selectedEmployeePhone = employees.first.userPhone;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final selectedEmp = employees.firstWhere((e) => e.userPhone == selectedEmployeePhone, orElse: () => employees.first);
          final isCurrentlyAssigned = lead.assignedTo.isNotEmpty && lead.assignedTo != '-';

          return AlertDialog(
            backgroundColor: AppColors.cardBackground,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: AppColors.border)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Icon(isCurrentlyAssigned ? Icons.replay_rounded : Icons.person_add_rounded, color: AppColors.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isCurrentlyAssigned ? 'Reassign Lead to Employee' : 'Assign Lead to Employee', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary)),
                      Text('Target Lead: ${lead.name} (${lead.phone})', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 440,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isCurrentlyAssigned) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: Color(0xFFF59E0B), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Already assigned to ${lead.assignedTo}. Aap is lead ko kisi aur employee ko reassign ya wapis revoke kar sakte hain.',
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  Text('Choose Employee / Telecaller:', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: employees.any((e) => e.userPhone == selectedEmployeePhone) ? selectedEmployeePhone : employees.first.userPhone,
                    dropdownColor: AppColors.cardBackground,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: AppColors.scaffoldBackground,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                    ),
                    items: employees.map((e) {
                      return DropdownMenuItem(value: e.userPhone, child: Text('${e.userName} (${e.userPhone})', style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedEmployeePhone = val);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              if (isCurrentlyAssigned)
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await WebLeadFirestoreService.unassignLead(lead.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Lead revoked back to Pending pool!')),
                      );
                      widget.onRefresh?.call();
                    }
                  },
                  child: const Text('Revoke to Pending', style: TextStyle(color: Color(0xFFEF4444))),
                ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await WebLeadFirestoreService.reassignLead(lead.id, selectedEmp.userName, selectedEmp.userPhone);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lead assigned to ${selectedEmp.userName}!'), backgroundColor: const Color(0xFF059669)),
                    );
                    widget.onRefresh?.call();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                child: Text(isCurrentlyAssigned ? 'Reassign' : 'Assign'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // MAIN BUILD METHOD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final user = WebAuthService.currentUser;
    final orgName = user?.companyName ?? user?.name ?? 'My Organization';
    final connectCode = user?.connectCode ?? '';

    return StreamBuilder<List<FirestoreDevice>>(
      stream: FirestoreSyncService.streamDevices(filterConnectCode: connectCode),
      builder: (context, snapshot) {
        final employees = snapshot.data ?? [];
        final query = _searchCtrl.text.toLowerCase().trim();

        // Time slot filter applied first
        final timeFilteredLeads = widget.leads.where(_matchesTimeSlot).toList();

        // Compartment split
        final pendingLeads = timeFilteredLeads.where(_isPendingLead).toList();
        final sentLeads = timeFilteredLeads.where((l) => !_isPendingLead(l)).toList();

        List<LeadItem> compartmentList;
        if (_activeCompartment == 'pending') {
          compartmentList = List.from(pendingLeads);
        } else if (_activeCompartment == 'sent') {
          compartmentList = List.from(sentLeads);
        } else {
          // All: Pending on top, Sent below
          compartmentList = List.from(timeFilteredLeads);
          compartmentList.sort((a, b) {
            final aP = _isPendingLead(a) ? 0 : 1;
            final bP = _isPendingLead(b) ? 0 : 1;
            if (aP != bP) return aP.compareTo(bP);
            return 0;
          });
        }

        // Search & employee filter
        final filtered = compartmentList.where((l) {
          if (_selectedEmployeeFilter != 'all') {
            if (l.assignedTo != _selectedEmployeeFilter && l.assignedToPhone != _selectedEmployeeFilter) {
              return false;
            }
          }
          if (query.isNotEmpty) {
            final mName = l.name.toLowerCase().contains(query);
            final mPhone = l.phone.toLowerCase().contains(query);
            final mAssign = l.assignedTo.toLowerCase().contains(query);
            final mCity = (l.city ?? '').toLowerCase().contains(query);
            if (!mName && !mPhone && !mAssign && !mCity) return false;
          }
          return true;
        }).toList();

        final totalPages = max(1, (filtered.length / _pageSize).ceil());
        final safePage = _currentPage.clamp(0, totalPages - 1);
        final startIndex = safePage * _pageSize;
        final pageItems = filtered.skip(startIndex).take(_pageSize).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Organization Banner
            _buildTopBanner(orgName, connectCode, pendingLeads, employees),
            const SizedBox(height: 16),

            // Summary Metrics Cards
            _buildMetricsCards(widget.leads.length, pendingLeads.length, sentLeads.length, employees.length),
            const SizedBox(height: 16),

            // View Mode Switcher: Table vs Team Hierarchy & Breakdown Graph
            _buildViewModeSwitcher(),
            const SizedBox(height: 16),

            if (_viewMode == 'tree')
              _buildHierarchyAndGraphView(timeFilteredLeads, employees, orgName, connectCode)
            else
              _buildTableView(
                employees,
                timeFilteredLeads,
                pendingLeads,
                sentLeads,
                filtered,
                pageItems,
                safePage,
                totalPages,
              ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TOP BANNER
  // ==========================================
  Widget _buildTopBanner(String orgName, String connectCode, List<LeadItem> pendingLeads, List<FirestoreDevice> employees) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 14,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 6,
                children: [
                  Text(
                    orgName,
                    style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      connectCode,
                      style: GoogleFonts.jetBrainsMono(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Super Admin se aayi hui leads yahan Pending rahengi. Auto ya Manual distribute karke Telecallers ko Sent karein.',
                style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),

          // Actions
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: pendingLeads.isEmpty ? null : () => _showAutoDistributeDialog(context, pendingLeads, employees),
                icon: const Icon(Icons.shuffle_rounded, size: 16),
                label: Text('Auto Distribute (${pendingLeads.length} Pending)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: pendingLeads.isEmpty ? null : () => _showManualQuotasDialog(context, pendingLeads, employees),
                icon: const Icon(Icons.edit_note_rounded, size: 16),
                label: const Text('Manual Quotas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (_selectedLeadIds.isNotEmpty) ...[
                ElevatedButton.icon(
                  onPressed: () => _showBulkAssignDialog(context, employees),
                  icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                  label: Text('Assign Selected (${_selectedLeadIds.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _confirmBulkRevoke(context),
                  icon: const Icon(Icons.undo_rounded, size: 16, color: Color(0xFFEF4444)),
                  label: Text('Revoke Selected (${_selectedLeadIds.length})', style: const TextStyle(color: Color(0xFFEF4444))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
              OutlinedButton.icon(
                onPressed: widget.onRefresh,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================
  // METRICS CARDS
  // ==========================================
  Widget _buildMetricsCards(int totalLeads, int pendingCount, int sentCount, int empCount) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final card1 = _buildMetricCard(
          title: 'Total Inflow Leads',
          value: '$totalLeads',
          subtitle: 'Received from Admin',
          icon: Icons.layers_rounded,
          color: AppColors.primary,
        );
        final card2 = _buildMetricCard(
          title: '⏳ Pending Leads',
          value: '$pendingCount',
          subtitle: 'Ready to distribute',
          icon: Icons.hourglass_top_rounded,
          color: const Color(0xFFF59E0B),
        );
        final card3 = _buildMetricCard(
          title: '✅ Sent to Telecallers',
          value: '$sentCount',
          subtitle: 'Active with Team',
          icon: Icons.check_circle_outline_rounded,
          color: const Color(0xFF10B981),
        );
        final card4 = _buildMetricCard(
          title: 'Organization Team',
          value: '$empCount Telecallers',
          subtitle: 'Connected mobile app',
          icon: Icons.people_alt_rounded,
          color: const Color(0xFF38BDF8),
        );

        if (constraints.maxWidth < 950) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: card1),
                  const SizedBox(width: 14),
                  Expanded(child: card2),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: card3),
                  const SizedBox(width: 14),
                  Expanded(child: card4),
                ],
              ),
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 14),
            Expanded(child: card2),
            const SizedBox(width: 14),
            Expanded(child: card3),
            const SizedBox(width: 14),
            Expanded(child: card4),
          ],
        );
      },
    );
  }

  // ==========================================
  // VIEW MODE SWITCHER
  // ==========================================
  Widget _buildViewModeSwitcher() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildViewButton(id: 'table', icon: Icons.table_chart_rounded, label: 'Leads Table & Distribution'),
          const SizedBox(width: 6),
          _buildViewButton(id: 'tree', icon: Icons.account_tree_rounded, label: '🌳 Team Hierarchy Flow & Share Records'),
        ],
      ),
    );
  }

  Widget _buildViewButton({required String id, required IconData icon, required String label}) {
    final isSelected = _viewMode == id;
    return InkWell(
      onTap: () => setState(() => _viewMode = id),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // HIERARCHY FLOW & QUOTA SHARE GRAPH VIEW
  // =========================================================================
  Widget _buildHierarchyAndGraphView(
    List<LeadItem> leads,
    List<FirestoreDevice> employees,
    String orgName,
    String connectCode,
  ) {
    final sentLeads = leads.where((l) => !_isPendingLead(l)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Quota Share Bar Graph
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
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
                      const Icon(Icons.bar_chart_rounded, size: 20, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 8),
                      Text(
                        'TELECALLER DISTRIBUTION SHARE & RECORDS',
                        style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  Text('${employees.length} Active Employees', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
              const SizedBox(height: 14),

              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 16,
                  color: AppColors.scaffoldBackground,
                  child: sentLeads.isNotEmpty
                      ? Row(
                          children: employees.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final emp = entry.value;
                            final empCount = sentLeads.where((l) => l.assignedTo == emp.userName || l.assignedToPhone == emp.userPhone).length;
                            final flex = ((empCount / sentLeads.length) * 1000).round();
                            if (flex <= 0) return const SizedBox.shrink();

                            return Expanded(
                              flex: flex,
                              child: Container(color: _getEmployeeColor(idx)),
                            );
                          }).toList(),
                        )
                      : Container(color: AppColors.scaffoldBackground),
                ),
              ),
              const SizedBox(height: 14),

              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: employees.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final emp = entry.value;
                  final empCount = sentLeads.where((l) => l.assignedTo == emp.userName || l.assignedToPhone == emp.userPhone).length;
                  final pct = sentLeads.isNotEmpty ? ((empCount / sentLeads.length) * 100).toStringAsFixed(1) : '0';
                  final color = _getEmployeeColor(idx);

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text('${emp.userName}: ', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                      Text('$empCount sent ($pct%)', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Organization Node (Level 2)
        Center(
          child: Container(
            width: 440,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.6), width: 1.5),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.domain_rounded, color: Color(0xFF38BDF8), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(orgName, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Text('Code: $connectCode • ${leads.length} Leads in Org', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
              ],
            ),
          ),
        ),

        // Flow Connector
        Center(
          child: Column(
            children: [
              Container(width: 2, height: 24, color: AppColors.primary),
              const Icon(Icons.south_rounded, size: 16, color: Color(0xFF10B981)),
              Container(width: 2, height: 24, color: AppColors.primary),
            ],
          ),
        ),

        // Telecallers Nodes (Level 3)
        Wrap(
          spacing: 20,
          runSpacing: 20,
          alignment: WrapAlignment.center,
          children: employees.asMap().entries.map((entry) {
            final idx = entry.key;
            final emp = entry.value;
            final empSent = sentLeads.where((l) => l.assignedTo == emp.userName || l.assignedToPhone == emp.userPhone).toList();
            final color = _getEmployeeColor(idx);

            return Container(
              width: 320,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.5), width: 1.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: color.withValues(alpha: 0.2),
                        child: Text(
                          emp.userName.isNotEmpty ? emp.userName[0].toUpperCase() : 'A',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp.userName, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                            Text(emp.userPhone, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: Text('${empSent.length} Leads', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Text('Model: ${emp.deviceModel ?? "Mobile Device"}', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
                  Text('Status: ${emp.status.toUpperCase()} • Calls: ${emp.totalCallsCount}', style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // =========================================================================
  // LEADS TABLE VIEW
  // =========================================================================
  Widget _buildTableView(
    List<FirestoreDevice> employees,
    List<LeadItem> timeFilteredLeads,
    List<LeadItem> pendingLeads,
    List<LeadItem> sentLeads,
    List<LeadItem> filtered,
    List<LeadItem> pageItems,
    int safePage,
    int totalPages,
  ) {
    return Column(
      children: [
        // Compartments & Filter Row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _buildCompartmentTab('pending', '⏳ Pending Leads', pendingLeads.length, const Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  _buildCompartmentTab('sent', '✅ Sent Leads', sentLeads.length, const Color(0xFF10B981)),
                  const SizedBox(width: 8),
                  _buildCompartmentTab('all', '📋 All Leads', timeFilteredLeads.length, AppColors.primary),
                ],
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  // Search
                  Expanded(
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() => _currentPage = 0),
                      decoration: InputDecoration(
                        hintText: 'Search by lead name, phone, city, or assigned employee...',
                        hintStyle: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary),
                        prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.textSecondary),
                        filled: true,
                        fillColor: AppColors.scaffoldBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.border)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Time Slot Filter Dropdown (Audio 2 requirement!)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.scaffoldBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedTimeSlot,
                        dropdownColor: AppColors.cardBackground,
                        style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('🕒 All Time')),
                          DropdownMenuItem(value: 'today', child: Text('📅 Today Only')),
                          DropdownMenuItem(value: 'morning', child: Text('🌅 Morning (6 AM - 12 PM)')),
                          DropdownMenuItem(value: 'afternoon', child: Text('☀️ Afternoon (12 PM - 6 PM)')),
                          DropdownMenuItem(value: 'evening', child: Text('🌙 Evening / Night (6 PM - 12 AM)')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedTimeSlot = val;
                              _currentPage = 0;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Filter by Employee Dropdown
                  if (employees.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedEmployeeFilter,
                          dropdownColor: AppColors.cardBackground,
                          style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary),
                          items: [
                            const DropdownMenuItem(value: 'all', child: Text('All Employees')),
                            ...employees.map((e) => DropdownMenuItem(value: e.userName, child: Text(e.userName))),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedEmployeeFilter = val;
                                _currentPage = 0;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // DataTable
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(AppColors.scaffoldBackground),
                  horizontalMargin: 20,
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('LEAD PROFILE')),
                    DataColumn(label: Text('LOCATION / COMPANY')),
                    DataColumn(label: Text('WEB STATUS')),
                    DataColumn(label: Text('ASSIGNED TELECALLER')),
                    DataColumn(label: Text('ACTIONS')),
                  ],
                  rows: pageItems.map((lead) {
                    final isLeadPending = _isPendingLead(lead);
                    final isSelected = _selectedLeadIds.contains(lead.id);

                    return DataRow(
                      selected: isSelected,
                      onSelectChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedLeadIds.add(lead.id);
                          } else {
                            _selectedLeadIds.remove(lead.id);
                          }
                        });
                      },
                      cells: [
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lead.name, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                              Row(
                                children: [
                                  const Icon(Icons.phone_rounded, size: 11, color: AppColors.primary),
                                  const SizedBox(width: 4),
                                  Text(lead.phone, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.primary)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(lead.company?.isNotEmpty == true ? lead.company! : 'Direct Lead', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textPrimary)),
                              Text('${lead.city ?? ""}${lead.state?.isNotEmpty == true ? ", ${lead.state}" : ""}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                        DataCell(
                          isLeadPending
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.hourglass_top_rounded, size: 12, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 4),
                                      Text('Pending', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFF59E0B))),
                                    ],
                                  ),
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.35)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF10B981)),
                                      const SizedBox(width: 4),
                                      Text('Sent', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                    ],
                                  ),
                                ),
                        ),
                        DataCell(
                          !isLeadPending
                              ? Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(color: const Color(0xFF10B981).withValues(alpha: 0.15), shape: BoxShape.circle),
                                      child: const Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(lead.assignedTo, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF10B981))),
                                        if (lead.assignedToPhone.isNotEmpty)
                                          Text(lead.assignedToPhone, style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondary)),
                                      ],
                                    ),
                                  ],
                                )
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.hourglass_empty_rounded, size: 12, color: Color(0xFFF59E0B)),
                                      const SizedBox(width: 5),
                                      Text('Pending Distribution', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFFF59E0B))),
                                    ],
                                  ),
                                ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              ElevatedButton(
                                onPressed: () => _showSingleAssignDialog(context, lead, employees),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: !isLeadPending ? AppColors.scaffoldBackground : const Color(0xFF10B981),
                                  foregroundColor: !isLeadPending ? AppColors.textPrimary : Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                child: Text(!isLeadPending ? 'Reassign' : 'Assign', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                              if (!isLeadPending) ...[
                                const SizedBox(width: 6),
                                OutlinedButton(
                                  onPressed: () async {
                                    await WebLeadFirestoreService.unassignLead(lead.id);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Lead revoked back to Pending pool!')),
                                      );
                                      widget.onRefresh?.call();
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFFEF4444)),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  ),
                                  child: const Text('Revoke', style: TextStyle(fontSize: 10.5, color: Color(0xFFEF4444))),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Pagination Footer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Showing ${pageItems.length} of ${filtered.length} leads', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left_rounded),
                          onPressed: safePage > 0 ? () => setState(() => _currentPage--) : null,
                        ),
                        Text('Page ${safePage + 1} of $totalPages', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        IconButton(
                          icon: const Icon(Icons.chevron_right_rounded),
                          onPressed: safePage < totalPages - 1 ? () => setState(() => _currentPage++) : null,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompartmentTab(String id, String title, int count, Color color) {
    final isSelected = _activeCompartment == id;

    return InkWell(
      onTap: () => setState(() {
        _activeCompartment = id;
        _currentPage = 0;
        _selectedLeadIds.clear();
      }),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.scaffoldBackground : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: AppColors.primary.withValues(alpha: 0.5)) : Border.all(color: Colors.transparent),
        ),
        child: Row(
          children: [
            Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
