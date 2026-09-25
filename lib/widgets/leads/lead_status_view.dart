import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

class LeadStatusView extends StatefulWidget {
  final List<LeadStatusModel> statuses;
  final ValueChanged<LeadStatusModel> onStatusAdded;
  final ValueChanged<LeadStatusModel> onStatusUpdated;
  final ValueChanged<String> onStatusDeleted;

  const LeadStatusView({
    super.key,
    required this.statuses,
    required this.onStatusAdded,
    required this.onStatusUpdated,
    required this.onStatusDeleted,
  });

  @override
  State<LeadStatusView> createState() => _LeadStatusViewState();
}

class _LeadStatusViewState extends State<LeadStatusView> {
  final List<String> _colorPresets = [
    '#3B82F6', // Blue
    '#6366F1', // Indigo
    '#F59E0B', // Amber
    '#10B981', // Emerald
    '#F97316', // Orange
    '#EC4899', // Pink
    '#8B5CF6', // Purple
    '#EF4444', // Red
  ];

  Color _parseHex(String hex) {
    try {
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) buffer.write('ff');
      buffer.write(hex.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  void _showAddEditDialog([LeadStatusModel? existing]) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    bool reminderRequired = existing?.isReminderRequired ?? false;
    bool defaultDisplay = existing?.isDefaultDisplay ?? true;
    String selectedHex = existing?.colorHex ?? _colorPresets.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: _parseHex(selectedHex), shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(isEdit ? 'Edit Pipeline Stage' : 'Add Pipeline Stage', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Stage / Status Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g., Quotation Sent, Follow Up', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8), border: OutlineInputBorder())),
                  const SizedBox(height: 14),
                  const Text('Stage Description & Automation Rule', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  TextField(controller: descCtrl, maxLines: 2, decoration: const InputDecoration(hintText: 'Description of what triggers or happens in this stage', contentPadding: EdgeInsets.all(10), border: OutlineInputBorder())),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Mandatory Follow-Up Reminder', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('If enabled, agents must select a reminder date/time before saving disposition in app', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    value: reminderRequired,
                    activeThumbColor: const Color(0xFFF59E0B),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDlgState(() => reminderRequired = val),
                  ),
                  SwitchListTile(
                    title: const Text('Default Display on Quick Disposition', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Show as a primary 1-tap chip when call ends on mobile screen', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                    value: defaultDisplay,
                    activeThumbColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => setDlgState(() => defaultDisplay = val),
                  ),
                  const SizedBox(height: 14),
                  const Text('Color Badge Indicator:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: _colorPresets.map((hex) {
                      final isSelected = selectedHex == hex;
                      return InkWell(
                        onTap: () => setDlgState(() => selectedHex = hex),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: _parseHex(hex),
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? const Color(0xFF1E293B) : Colors.white, width: isSelected ? 2.5 : 1),
                            boxShadow: [if (isSelected) const BoxShadow(color: Colors.black26, blurRadius: 4)],
                          ),
                          child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                if (isEdit) {
                  final updated = existing.copyWith(
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    isReminderRequired: reminderRequired,
                    isDefaultDisplay: defaultDisplay,
                    colorHex: selectedHex,
                  );
                  widget.onStatusUpdated(updated);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stage updated.')));
                } else {
                  final newStatus = LeadStatusModel(
                    id: 'st_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    description: descCtrl.text.trim(),
                    isReminderRequired: reminderRequired,
                    isDefaultDisplay: defaultDisplay,
                    order: widget.statuses.length + 1,
                    colorHex: selectedHex,
                  );
                  widget.onStatusAdded(newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pipeline stage added successfully.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: Text(isEdit ? 'Save Changes' : 'Create Stage'),
            ),
          ],
        ),
      ),
    );
  }

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
          // Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Lead Status & Pipeline Stages', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      SizedBox(height: 2),
                      Text('Configure dispositions, mandatory follow-up triggers, and default post-call chips.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditDialog(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Pipeline Stage'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Data Table
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 24,
                    horizontalMargin: 24,
                    columns: const [
                      DataColumn(label: Text('# Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Status Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Description & Automation Rule', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Reminder Required?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Default Display?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13))),
                    ],
                    rows: widget.statuses.map((st) {
                      final badgeColor = _parseHex(st.colorHex);
                      return DataRow(cells: [
                        DataCell(CircleAvatar(radius: 12, backgroundColor: const Color(0xFFF1F5F9), child: Text('${st.order}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))))),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(4)),
                                child: Text(st.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: badgeColor)),
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text(st.description, style: const TextStyle(fontSize: 12.5, color: Color(0xFF334155)))),
                        DataCell(
                          st.isReminderRequired
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('YES (Mandatory)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                                )
                              : const Text('No', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ),
                        DataCell(
                          st.isDefaultDisplay
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(4)),
                                  child: const Text('Visible', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857))),
                                )
                              : const Text('Hidden', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                tooltip: 'Edit Stage',
                                onPressed: () => _showAddEditDialog(st),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                tooltip: 'Delete Stage',
                                onPressed: () {
                                  widget.onStatusDeleted(st.id);
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stage deleted.')));
                                },
                              ),
                            ],
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
