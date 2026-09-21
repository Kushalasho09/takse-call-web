import 'package:flutter/material.dart';

class CreateCallNoteTemplateView extends StatefulWidget {
  final Map<String, dynamic>? initialTemplate;
  final VoidCallback onBack;
  final Function(Map<String, dynamic> templateData) onSave;

  const CreateCallNoteTemplateView({
    super.key,
    this.initialTemplate,
    required this.onBack,
    required this.onSave,
  });

  @override
  State<CreateCallNoteTemplateView> createState() => _CreateCallNoteTemplateViewState();
}

class _CreateCallNoteTemplateViewState extends State<CreateCallNoteTemplateView> {
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  String? _titleError;
  String? _descError;

  @override
  void initState() {
    super.initState();
    if (widget.initialTemplate != null) {
      _titleCtrl.text = widget.initialTemplate!['title'] ?? '';
      _descCtrl.text = widget.initialTemplate!['description'] ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    setState(() {
      _titleError = _titleCtrl.text.trim().isEmpty ? 'Please enter a title' : null;
      _descError = _descCtrl.text.trim().isEmpty ? 'Please enter a description' : null;
    });

    if (_titleError != null || _descError != null) return;

    final templateData = {
      'id': widget.initialTemplate != null
          ? widget.initialTemplate!['id']
          : DateTime.now().millisecondsSinceEpoch,
      'title': _titleCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'modifiedOn': _formatCurrentDate(),
    };

    widget.onSave(templateData);
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year;
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final min = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$min $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialTemplate != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isEditing ? 'Edit Call Note Template' : 'Create Call Note Template',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFF59E0B), width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.chevron_left_rounded, size: 18, color: Color(0xFFF59E0B)),
                      SizedBox(width: 4),
                      Text(
                        'Back',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Body Form
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Field
                TextField(
                  controller: _titleCtrl,
                  onChanged: (_) {
                    if (_titleError != null) {
                      setState(() => _titleError = null);
                    }
                  },
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    label: RichText(
                      text: const TextSpan(
                        text: 'Title ',
                        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                        children: [
                          TextSpan(text: '*', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    hintText: 'Enter Template Title',
                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    errorText: _titleError,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF93C5FD), width: 1.8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: 24),

                // Description Field
                Stack(
                  children: [
                    TextField(
                      controller: _descCtrl,
                      maxLines: null,
                      minLines: 12,
                      maxLength: 1000,
                      buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                      onChanged: (_) {
                        setState(() {
                          if (_descError != null) _descError = null;
                        });
                      },
                      style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A), height: 1.5),
                      decoration: InputDecoration(
                        label: RichText(
                          text: const TextSpan(
                            text: 'Description ',
                            style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
                            children: [
                              TextSpan(text: '*', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        alignLabelWithHint: true,
                        hintText: 'Enter your description here...',
                        hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                        errorText: _descError,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: Color(0xFF93C5FD), width: 1.8),
                        ),
                        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Text(
                        '${_descCtrl.text.length}/1000',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Bottom Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: widget.onBack,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Cancel', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 14),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                  child: const Text('Save', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
