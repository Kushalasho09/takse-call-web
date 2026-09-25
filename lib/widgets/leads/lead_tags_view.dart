import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

class LeadTagsView extends StatefulWidget {
  final List<LeadTagModel> tags;
  final ValueChanged<LeadTagModel> onTagAdded;
  final ValueChanged<LeadTagModel> onTagUpdated;
  final ValueChanged<String> onTagDeleted;

  const LeadTagsView({
    super.key,
    required this.tags,
    required this.onTagAdded,
    required this.onTagUpdated,
    required this.onTagDeleted,
  });

  @override
  State<LeadTagsView> createState() => _LeadTagsViewState();
}

class _LeadTagsViewState extends State<LeadTagsView> {
  final List<String> _colorPresets = [
    '#EF4444', // Red
    '#10B981', // Emerald
    '#EC4899', // Pink
    '#F59E0B', // Amber
    '#3B82F6', // Blue
    '#8B5CF6', // Purple
    '#06B6D4', // Cyan
    '#1E293B', // Slate
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

  void _showAddEditTagModal([LeadTagModel? existing]) {
    final isEdit = existing != null;
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    String selectedHex = existing?.colorHex ?? _colorPresets.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          title: Text(isEdit ? 'Edit Lead Tag' : 'Create New Lead Tag', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tag Label / Name *', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(controller: nameCtrl, decoration: const InputDecoration(hintText: 'e.g., High Budget, Urgent, Instagram', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8))),
                const SizedBox(height: 16),
                const Text('Tag Color Indicator:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
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
                const SizedBox(height: 16),
                const Text('Preview Chip:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: _parseHex(selectedHex).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: _parseHex(selectedHex))),
                  child: Text(nameCtrl.text.isEmpty ? 'Sample Tag' : nameCtrl.text, style: TextStyle(color: _parseHex(selectedHex), fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx);
                if (isEdit) {
                  final updated = existing.copyWith(name: nameCtrl.text.trim(), colorHex: selectedHex);
                  widget.onTagUpdated(updated);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag updated.')));
                } else {
                  final now = DateTime.now();
                  final newTag = LeadTagModel(
                    id: 'tag_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameCtrl.text.trim(),
                    colorHex: selectedHex,
                    leadCount: 0,
                    createdAt: '${now.day} Sep 2026',
                  );
                  widget.onTagAdded(newTag);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead tag created.')));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: Text(isEdit ? 'Save Changes' : 'Create Tag'),
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
                      Text('Lead Tags & Segments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      SizedBox(height: 2),
                      Text('Organize leads with colorful segment tags for instant telecaller identification.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => _showAddEditTagModal(),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Create Tag'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Tag Grid Cards
          Padding(
            padding: const EdgeInsets.all(24),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                mainAxisExtent: 125,
              ),
              itemCount: widget.tags.length,
              itemBuilder: (context, index) {
                final tag = widget.tags[index];
                final col = _parseHex(tag.colorHex);

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Color(0x03000000), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Container(width: 14, height: 14, decoration: BoxDecoration(color: col, shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(tag.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B)), overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 4),
                            Text('${tag.leadCount} active leads • ${tag.createdAt}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        tooltip: 'Edit Tag',
                        onPressed: () => _showAddEditTagModal(tag),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                        tooltip: 'Delete Tag',
                        onPressed: () {
                          widget.onTagDeleted(tag.id);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tag deleted.')));
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
