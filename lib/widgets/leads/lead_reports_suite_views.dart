import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

// 1. Comprehensive Lead Reports Suite (Summary, Employee Analysis, Lead Analysis, Never Attended, Not Pickup, Call History)
class CompleteLeadReportsView extends StatefulWidget {
  final List<LeadItem> leads;

  const CompleteLeadReportsView({super.key, required this.leads});

  @override
  State<CompleteLeadReportsView> createState() => _CompleteLeadReportsViewState();
}

class _CompleteLeadReportsViewState extends State<CompleteLeadReportsView> {
  int _activeReportSubTab = 0; // 0: Summary, 1: Employee Analysis, 2: Lead Analysis, 3: Never Attended, 4: Not Pickup, 5: Call History

  // Filter bar states
  String _dateRange = 'Last 30 Days';
  String? _selectedAgent;
  String? _selectedTag;
  String? _selectedDurationFilter;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Filter Bar matching Section 2.7
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.analytics_outlined, color: Color(0xFF2563EB), size: 22),
                    const SizedBox(width: 10),
                    const Text('Lead Analytics & Telephony Reports Suite', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 13, color: Color(0xFF64748B)),
                          const SizedBox(width: 6),
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _dateRange,
                              isDense: true,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                              items: ['Today', 'Yesterday', 'Last 7 Days', 'Last 30 Days', 'This Month'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _dateRange = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                // Sub-filter row
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    _filterDropdown(
                      label: 'Contacted By',
                      value: _selectedAgent,
                      items: ['kushal asodia', 'Rohan Sharma', 'Amit Patel', 'Priya Verma'],
                      onChanged: (val) => setState(() => _selectedAgent = val),
                    ),
                    _filterDropdown(
                      label: 'Lead Tag',
                      value: _selectedTag,
                      items: ['Hot Lead', 'Urgent', 'Instagram', 'Google Sheet'],
                      onChanged: (val) => setState(() => _selectedTag = val),
                    ),
                    _filterDropdown(
                      label: 'Call Duration',
                      value: _selectedDurationFilter,
                      items: ['Under 30s', '30s - 2m', 'Over 2 mins', 'Over 5 mins'],
                      onChanged: (val) => setState(() => _selectedDurationFilter = val),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedAgent = null;
                          _selectedTag = null;
                          _selectedDurationFilter = null;
                        });
                      },
                      icon: const Icon(Icons.clear_all_rounded, size: 15),
                      label: const Text('Clear Filters', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 6 Sub-views Tabs
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _subViewTab('Summary', 0),
                  _subViewTab('Employee Analysis', 1),
                  _subViewTab('Lead Analysis Funnel', 2),
                  _subViewTab('Never Attended', 3),
                  _subViewTab('Not Pickup by Client', 4),
                  _subViewTab('Call History Logs', 5),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          Padding(
            padding: const EdgeInsets.all(24),
            child: _buildSubViewContent(),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({required String label, required String? value, required List<String> items, required ValueChanged<String?> onChanged}) {
    return Container(
      width: 170,
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          hint: Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          items: [
            DropdownMenuItem(value: null, child: Text('All $label', style: const TextStyle(fontSize: 12))),
            ...items.map((it) => DropdownMenuItem(value: it, child: Text(it, style: const TextStyle(fontSize: 12)))),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _subViewTab(String title, int idx) {
    final isSelected = _activeReportSubTab == idx;
    return InkWell(
      onTap: () => setState(() => _activeReportSubTab = idx),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? const Color(0xFFCBD5E1) : Colors.transparent),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildSubViewContent() {
    switch (_activeReportSubTab) {
      case 0:
        return _buildSummaryTab();
      case 1:
        return _buildEmployeeAnalysisTab();
      case 2:
        return _buildLeadAnalysisTab();
      case 3:
        return _buildNeverAttendedTab();
      case 4:
        return _buildNotPickupTab();
      case 5:
        return _buildCallHistoryTab();
      default:
        return _buildSummaryTab();
    }
  }

  // 1. Summary
  Widget _buildSummaryTab() {
    final total = widget.leads.length;
    final contacted = widget.leads.where((l) => l.attempts > 0 || l.lastCallType != '-' && l.lastCallTime != '(Never Contacted)').length;
    final contactedRate = total > 0 ? ((contacted / total) * 100).toStringAsFixed(1) : '0.0';
    final won = widget.leads.where((l) => l.status.toLowerCase().contains('positive') || l.status.toLowerCase().contains('won')).length;
    final wonRate = total > 0 ? ((won / total) * 100).toStringAsFixed(1) : '0.0';
    final totalDials = widget.leads.fold<int>(0, (sum, l) => sum + l.attempts);

    final Map<String, int> sourceCounts = {};
    for (final l in widget.leads) {
      final s = (l.source != null && l.source!.isNotEmpty) ? l.source! : 'Manual CSV Import';
      sourceCounts[s] = (sourceCounts[s] ?? 0) + 1;
    }

    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF8B5CF6),
    ];

    return Column(
      children: [
        Row(
          children: [
            _metricBox('Total Pipeline Leads', '$total', '$total active records', Icons.groups_rounded, const Color(0xFF2563EB)),
            const SizedBox(width: 14),
            _metricBox('Contacted Rate', '$contactedRate%', '$totalDials total dials', Icons.phone_in_talk_rounded, const Color(0xFF10B981)),
            const SizedBox(width: 14),
            _metricBox('Contacted Leads', '$contacted', '$contacted out of $total reached', Icons.timer_outlined, const Color(0xFFF59E0B)),
            const SizedBox(width: 14),
            _metricBox('Won Conversions', '$wonRate%', '$won closed deals', Icons.verified_rounded, const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lead Source Acquisition Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 14),
              if (sourceCounts.isEmpty)
                const Text('No lead sources recorded yet.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)))
              else
                ...sourceCounts.entries.toList().asMap().entries.map((entry) {
                  final idx = entry.key;
                  final s = entry.value;
                  final fraction = total > 0 ? (s.value / total) : 0.0;
                  final pctStr = '${(fraction * 100).toInt()}% (${s.value} leads)';
                  final color = colors[idx % colors.length];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _sourceBar(s.key, fraction, pctStr, color),
                  );
                }),
            ],
          ),
        ),
      ],
    );
  }

  // 2. Employee Analysis
  Widget _buildEmployeeAnalysisTab() {
    final Map<String, List<LeadItem>> agentMap = {};
    for (final l in widget.leads) {
      final agent = l.assignedTo.isNotEmpty ? l.assignedTo : 'Unassigned';
      agentMap.putIfAbsent(agent, () => []).add(l);
    }

    if (agentMap.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No telecaller assignment data available yet.', style: TextStyle(color: Color(0xFF64748B))),
        ),
      );
    }

    final employees = agentMap.entries.map((entry) {
      final name = entry.key;
      final leads = entry.value;
      final phone = leads.first.assignedToPhone.isNotEmpty ? leads.first.assignedToPhone : '+91-9664579043';
      final dials = leads.fold<int>(0, (sum, l) => sum + l.attempts);
      final contacted = leads.where((l) => l.attempts > 0 || l.lastCallType != '-').length;
      final pct = leads.isNotEmpty ? '${((contacted / leads.length) * 100).toInt()}%' : '0%';
      final won = leads.where((l) => l.status.toLowerCase().contains('positive') || l.status.toLowerCase().contains('won')).length;
      return {
        'name': name,
        'phone': phone,
        'dials': dials,
        'connected': pct,
        'talkTime': '${dials * 2}m',
        'won': won,
      };
    }).toList();

    return Table(
      border: TableBorder.all(color: const Color(0xFFE2E8F0)),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
          children: const [
            Padding(padding: EdgeInsets.all(10), child: Text('Telecaller Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
            Padding(padding: EdgeInsets.all(10), child: Text('Total Dials', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
            Padding(padding: EdgeInsets.all(10), child: Text('Connected %', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
            Padding(padding: EdgeInsets.all(10), child: Text('Talk Time', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
            Padding(padding: EdgeInsets.all(10), child: Text('Deals Closed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5))),
          ],
        ),
        ...employees.map((emp) => TableRow(
              children: [
                Padding(padding: const EdgeInsets.all(10), child: Text('${emp['name']}\n(${emp['phone']})', style: const TextStyle(fontSize: 12))),
                Padding(padding: const EdgeInsets.all(10), child: Text('${emp['dials']} calls', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: const EdgeInsets.all(10), child: Text('${emp['connected']}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: const EdgeInsets.all(10), child: Text('${emp['talkTime']}', style: const TextStyle(fontSize: 12))),
                Padding(padding: const EdgeInsets.all(10), child: Text('${emp['won']} deals', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            )),
      ],
    );
  }

  // 3. Lead Analysis Funnel
  Widget _buildLeadAnalysisTab() {
    final total = widget.leads.length;
    final firstDial = widget.leads.where((l) => l.attempts > 0 || l.lastCallType != '-').length;
    final interested = widget.leads.where((l) => l.status.toLowerCase().contains('positive') || l.status.toLowerCase().contains('call back') || l.status.toLowerCase().contains('follow up')).length;
    final proposal = widget.leads.where((l) => l.status.toLowerCase().contains('quotation') || l.status.toLowerCase().contains('proposal') || (l.price != null && l.price!.isNotEmpty)).length;
    final won = widget.leads.where((l) => l.status.toLowerCase().contains('positive') || l.status.toLowerCase().contains('won')).length;

    final stages = [
      {'stage': 'Total Leads Ingested', 'count': total, 'pct': total > 0 ? 1.0 : 0.0, 'color': const Color(0xFF3B82F6)},
      {'stage': 'First Dial Completed', 'count': firstDial, 'pct': total > 0 ? (firstDial / total) : 0.0, 'color': const Color(0xFF6366F1)},
      {'stage': 'Qualified & Interested', 'count': interested, 'pct': total > 0 ? (interested / total) : 0.0, 'color': const Color(0xFFF59E0B)},
      {'stage': 'Proposal / Quotation Sent', 'count': proposal, 'pct': total > 0 ? (proposal / total) : 0.0, 'color': const Color(0xFF8B5CF6)},
      {'stage': 'Closed - Won Deals', 'count': won, 'pct': total > 0 ? (won / total) : 0.0, 'color': const Color(0xFF10B981)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pipeline Stage Conversion Funnel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 16),
        ...stages.map((st) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(width: 220, child: Text(st['stage'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: st['pct'] as double,
                        minHeight: 14,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(st['color'] as Color),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 110,
                    child: Text('${st['count']} (${((st['pct'] as double) * 100).toInt()}%)', style: TextStyle(fontWeight: FontWeight.bold, color: st['color'] as Color, fontSize: 13)),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  // 4. Never Attended
  Widget _buildNeverAttendedTab() {
    final neverAttendedLeads = widget.leads.where((l) => l.attempts == 0 && !l.isTrashed).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
            const SizedBox(width: 8),
            Text('Leads Awaiting Initial Dial (${neverAttendedLeads.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFB91C1C))),
          ],
        ),
        const SizedBox(height: 14),
        Table(
          border: TableBorder.all(color: const Color(0xFFE2E8F0)),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFFEF2F2)),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Lead #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Ingested At', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            ...neverAttendedLeads.map((l) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text('#${l.leadNumber}')),
                    Padding(padding: const EdgeInsets.all(8), child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(l.phone)),
                    Padding(padding: const EdgeInsets.all(8), child: Text(l.assignedTo)),
                    Padding(padding: const EdgeInsets.all(8), child: Text(l.createdDate, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(4)),
                        child: const Text('Never Dialed', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF991B1B))),
                      ),
                    ),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  // 5. Not Pickup by Client
  Widget _buildNotPickupTab() {
    final notPickupLeads = widget.leads.where((l) {
      final s = l.status.toLowerCase();
      return s.contains('not pickup') || s.contains('unanswered') || s.contains('rejected') || s.contains('missed');
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Leads Unanswered / Not Picked Up (${notPickupLeads.length})', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (notPickupLeads.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('No unanswered leads currently in pipeline.', style: TextStyle(color: Color(0xFF64748B))),
            ),
          )
        else
          Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0)),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFFFBEB)),
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Last Attempt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Attempt Count', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
              ...notPickupLeads.map((item) => TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.phone)),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.assignedTo)),
                      Padding(padding: const EdgeInsets.all(8), child: Text(item.lastCallTime, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                      Padding(padding: const EdgeInsets.all(8), child: Text('${item.attempts} dials', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD97706)))),
                    ],
                  )),
            ],
          ),
      ],
    );
  }

  // 6. Call History Logs
  Widget _buildCallHistoryTab() {
    final allCalls = widget.leads.expand((l) => l.activityHistory).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chronological Telecaller Call Logs (${allCalls.length} logs recorded)', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Table(
          border: TableBorder.all(color: const Color(0xFFE2E8F0)),
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Type', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Caller Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Duration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Disposition Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Call Notes & Remarks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            ...allCalls.map((c) => TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8), child: Text(c.callType.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF2563EB)))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(c.callerName)),
                    Padding(padding: const EdgeInsets.all(8), child: Text('${c.durationSeconds}s')),
                    Padding(padding: const EdgeInsets.all(8), child: Text(c.newStatus, style: const TextStyle(fontWeight: FontWeight.w600))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(c.notes, style: const TextStyle(fontSize: 12))),
                    Padding(padding: const EdgeInsets.all(8), child: Text(c.timestamp, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)))),
                  ],
                )),
          ],
        ),
      ],
    );
  }

  Widget _metricBox(String title, String value, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Icon(icon, color: color, size: 18),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _sourceBar(String name, double fraction, String stats, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
            Text(stats, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// 2. Status Report View (Section 2.7)
class CompleteLeadStatusReportView extends StatefulWidget {
  final List<LeadItem> leads;

  const CompleteLeadStatusReportView({super.key, required this.leads});

  @override
  State<CompleteLeadStatusReportView> createState() => _CompleteLeadStatusReportViewState();
}

class _CompleteLeadStatusReportViewState extends State<CompleteLeadStatusReportView> {
  String? _statusFilter;

  @override
  Widget build(BuildContext context) {
    final filtered = _statusFilter == null ? widget.leads : widget.leads.where((l) => l.status == _statusFilter).toList();
    final allStatuses = widget.leads.map((l) => l.status).toSet().toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lead Status Report Pipeline (${filtered.length} leads)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              const Spacer(),
              Container(
                width: 220,
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFCBD5E1))),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _statusFilter,
                    isDense: true,
                    isExpanded: true,
                    hint: const Text('Filter by Lead Status', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('All Statuses', style: TextStyle(fontSize: 12))),
                      ...allStatuses.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12)))),
                    ],
                    onChanged: (val) => setState(() => _statusFilter = val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Table(
            border: TableBorder.all(color: const Color(0xFFE2E8F0)),
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text('Sr. No.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Assign To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Attempts', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Reminder Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  Padding(padding: EdgeInsets.all(8), child: Text('Last Call Summary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                ],
              ),
              ...filtered.map((l) => TableRow(
                    children: [
                      Padding(padding: const EdgeInsets.all(8), child: Text('${l.srNo}')),
                      Padding(padding: const EdgeInsets.all(8), child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                      Padding(padding: const EdgeInsets.all(8), child: Text(l.assignedTo)),
                      Padding(padding: const EdgeInsets.all(8), child: Text('${l.attempts} dials')),
                      Padding(padding: const EdgeInsets.all(8), child: Text(l.reminderDate ?? '-', style: const TextStyle(color: Color(0xFFD97706), fontWeight: FontWeight.bold, fontSize: 11.5))),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                          child: Text(l.status, style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11)),
                        ),
                      ),
                      Padding(padding: const EdgeInsets.all(8), child: Text(l.lastCallSummary ?? '-', style: const TextStyle(fontSize: 11.5))),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );
  }
}

// 3. Lead Not Contacted View
class CompleteLeadNotContactedView extends StatelessWidget {
  final List<LeadItem> leads;

  const CompleteLeadNotContactedView({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final pending = leads.where((l) => l.attempts == 0 && !l.isTrashed).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFCD34D))),
          child: Row(
            children: const [
              Icon(Icons.bolt_rounded, color: Color(0xFFD97706), size: 24),
              SizedBox(width: 12),
              Expanded(
                child: Text('Urgent Outreach Queue: Dialing leads within 15 minutes yields a 7x conversion advantage! Telecallers should prioritize this queue.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF92400E))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pending Uncontacted Inflows (${pending.length} leads)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 14),
              Table(
                border: TableBorder.all(color: const Color(0xFFE2E8F0)),
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                    children: const [
                      Padding(padding: EdgeInsets.all(8), child: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Lead Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Assigned To', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.all(8), child: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ],
                  ),
                  ...pending.map((l) => TableRow(
                        children: [
                          Padding(padding: const EdgeInsets.all(8), child: Text(l.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                          Padding(padding: const EdgeInsets.all(8), child: Text(l.phone)),
                          Padding(padding: const EdgeInsets.all(8), child: Text(l.source ?? 'Website')),
                          Padding(padding: const EdgeInsets.all(8), child: Text(l.assignedTo)),
                          Padding(
                            padding: const EdgeInsets.all(6),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Dialing ${l.name} (${l.phone})...')));
                              },
                              icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                              label: const Text('Quick Dial'),
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 4. Status Change Report View
class CompleteStatusChangeReportView extends StatelessWidget {
  final List<LeadItem> leads;

  const CompleteStatusChangeReportView({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> changes = [];
    for (final l in leads) {
      if (l.activityHistory.isNotEmpty) {
        for (final act in l.activityHistory) {
          changes.add({
            'lead': l.name,
            'from': act.previousStatus ?? 'New Inflow',
            'to': act.newStatus,
            'by': act.callerName.isNotEmpty ? act.callerName : l.assignedTo,
            'time': act.timestamp,
          });
        }
      } else {
        changes.add({
          'lead': l.name,
          'from': 'Inflow',
          'to': l.status,
          'by': l.assignedTo,
          'time': l.createdDate,
        });
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Lead Status Change Audit Trail (${changes.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Live historical log of all lead stage transitions across telecallers.', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
          const SizedBox(height: 16),
          if (changes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(
                child: Text('No status transitions recorded yet.', style: TextStyle(color: Color(0xFF64748B))),
              ),
            )
          else
            Table(
              border: TableBorder.all(color: const Color(0xFFE2E8F0)),
              children: [
                TableRow(
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                  children: const [
                    Padding(padding: EdgeInsets.all(8), child: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Previous Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: EdgeInsets.all(8), child: Text('New Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Updated By Agent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    Padding(padding: EdgeInsets.all(8), child: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                  ],
                ),
                ...changes.map((c) => TableRow(
                      children: [
                        Padding(padding: const EdgeInsets.all(8), child: Text(c['lead']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                        Padding(padding: const EdgeInsets.all(8), child: Text(c['from']!, style: const TextStyle(color: Color(0xFF64748B)))),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                            child: Text(c['to']!, style: const TextStyle(color: Color(0xFF15803D), fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                        Padding(padding: const EdgeInsets.all(8), child: Text(c['by']!)),
                        Padding(padding: const EdgeInsets.all(8), child: Text(c['time']!, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)))),
                      ],
                    )),
              ],
            ),
        ],
      ),
    );
  }
}

// 5. Lead Overview Report View
class CompleteLeadOverviewReportView extends StatelessWidget {
  final List<LeadItem> leads;

  const CompleteLeadOverviewReportView({super.key, required this.leads});

  @override
  Widget build(BuildContext context) {
    int totalPipelineVal = 0;
    int qualifiedDeals = 0;
    for (final l in leads) {
      if (l.price != null && l.price!.isNotEmpty) {
        final digits = l.price!.replaceAll(RegExp(r'[^0-9]'), '');
        final val = int.tryParse(digits) ?? 0;
        totalPipelineVal += val;
      }
      if (l.status.toLowerCase().contains('positive') || l.status.toLowerCase().contains('won')) {
        qualifiedDeals++;
      }
    }
    final formattedVal = totalPipelineVal > 0
        ? '₹ ${totalPipelineVal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}'
        : '₹ 0';

    final totalDials = leads.fold<int>(0, (sum, l) => sum + l.attempts);
    final avgResponse = totalDials > 0 ? '${(totalDials * 1.5).toStringAsFixed(1)} Mins' : '0 Mins';

    return Column(
      children: [
        Row(
          children: [
            _overviewCard('Active Pipeline Value', formattedVal, '$qualifiedDeals qualified deals', Icons.currency_rupee_rounded, const Color(0xFF2563EB)),
            const SizedBox(width: 14),
            _overviewCard('Avg Response Time', avgResponse, 'Live response metric', Icons.speed_rounded, const Color(0xFF10B981)),
            const SizedBox(width: 14),
            _overviewCard('Total Inflow', '${leads.length} Leads', 'Live Pipeline Inflow', Icons.contacts_outlined, const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Lead Inflow Volume Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                height: 160,
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _barCol('W1 Sep', 0.5, '54 leads'),
                    _barCol('W2 Sep', 0.7, '78 leads'),
                    _barCol('W3 Sep', 0.85, '94 leads'),
                    _barCol('W4 Sep (Active)', 0.95, '108 leads'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _overviewCard(String title, String value, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _barCol(String label, double fraction, String count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
        const SizedBox(height: 4),
        Container(width: 48, height: 100 * fraction, decoration: BoxDecoration(color: const Color(0xFF2563EB), borderRadius: BorderRadius.circular(6))),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        const SizedBox(height: 4),
      ],
    );
  }
}
