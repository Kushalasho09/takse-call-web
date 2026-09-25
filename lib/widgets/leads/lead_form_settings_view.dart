// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

class LeadFormSettingsView extends StatefulWidget {
  final List<FormFieldSettingModel> fields;
  final ValueChanged<List<FormFieldSettingModel>> onFieldsUpdated;

  const LeadFormSettingsView({
    super.key,
    required this.fields,
    required this.onFieldsUpdated,
  });

  @override
  State<LeadFormSettingsView> createState() => _LeadFormSettingsViewState();
}

class _LeadFormSettingsViewState extends State<LeadFormSettingsView> {
  late List<FormFieldSettingModel> _activeFields;
  int _activeTab = 0; // 0: Form Field Builder, 1: Live Telecaller Preview

  final List<Map<String, dynamic>> _fieldTypes = [
    {'type': 'inputText', 'label': 'Input Field', 'icon': Icons.text_fields_rounded, 'desc': 'Single line text input'},
    {'type': 'numericField', 'label': 'Numeric Field', 'icon': Icons.pin_rounded, 'desc': 'Numbers, budgets, quantities'},
    {'type': 'emailField', 'label': 'Email Field', 'icon': Icons.email_outlined, 'desc': 'Email format validation'},
    {'type': 'websiteField', 'label': 'Website Field', 'icon': Icons.language_rounded, 'desc': 'Website URL link'},
    {'type': 'textArea', 'label': 'Text Area', 'icon': Icons.notes_rounded, 'desc': 'Multi-line notes and remarks'},
    {'type': 'checkBoxGroup', 'label': 'CheckBox Group', 'icon': Icons.check_box_outlined, 'desc': 'Multiple choice checklist'},
    {'type': 'radioGroup', 'label': 'Radio Group', 'icon': Icons.radio_button_checked_rounded, 'desc': 'Single select radio choices'},
    {'type': 'dropDown', 'label': 'DropDown', 'icon': Icons.arrow_drop_down_circle_outlined, 'desc': 'Dropdown selection list'},
    {'type': 'datePicker', 'label': 'DatePicker', 'icon': Icons.calendar_month_outlined, 'desc': 'Date selection calendar'},
  ];

  @override
  void initState() {
    super.initState();
    _activeFields = List.from(widget.fields);
  }

  void _addNewField(String type, String defaultLabel) {
    if (_activeFields.length >= 40) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum limit reached: You can configure up to 40 fields.')),
      );
      return;
    }

    final newField = FormFieldSettingModel(
      id: 'field_${DateTime.now().millisecondsSinceEpoch}',
      label: 'New $defaultLabel',
      fieldType: type,
      isRequired: false,
      options: (type == 'dropDown' || type == 'radioGroup' || type == 'checkBoxGroup') ? ['Option 1', 'Option 2', 'Option 3'] : [],
      order: _activeFields.length + 1,
    );

    setState(() {
      _activeFields.add(newField);
    });
    widget.onFieldsUpdated(_activeFields);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added "$defaultLabel" to canvas.')),
    );
  }

  void _removeField(int index) {
    setState(() {
      _activeFields.removeAt(index);
    });
    widget.onFieldsUpdated(_activeFields);
  }

  void _showEditOptionsDialog(int index) {
    final field = _activeFields[index];
    final optionsCtrl = TextEditingController(text: field.options.join('\n'));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Choices for "${field.label}"'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Enter one choice per line:', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
              const SizedBox(height: 10),
              TextField(
                controller: optionsCtrl,
                maxLines: 5,
                decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Option 1\nOption 2\nOption 3'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newOpts = optionsCtrl.text.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
              setState(() {
                _activeFields[index] = field.copyWith(options: newOpts);
              });
              widget.onFieldsUpdated(_activeFields);
              Navigator.pop(ctx);
            },
            child: const Text('Save Choices'),
          ),
        ],
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
          // Header Bar with Counter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Custom Lead Form Settings & Dynamic Schema', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Text('You can add up to 40 fields. ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(4)),
                            child: Text('Active: ${_activeFields.length} / 40', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      _tabButton('Visual Builder', 0),
                      _tabButton('Live Telecaller Form Preview', 1),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          if (_activeTab == 0) _buildBuilderPane() else _buildPreviewPane(),
        ],
      ),
    );
  }

  Widget _tabButton(String title, int idx) {
    final isSelected = _activeTab == idx;
    return InkWell(
      onTap: () => setState(() => _activeTab = idx),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(title, style: TextStyle(fontSize: 12.5, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
      ),
    );
  }

  // Builder Pane (Left Toolbar + Right Canvas)
  Widget _buildBuilderPane() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Palette (8 Callyzer field types)
          SizedBox(
            width: 250,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AVAILABLE FIELD TYPES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
                const SizedBox(height: 6),
                const Text('Click any component to append to your form canvas:', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                const SizedBox(height: 14),

                ..._fieldTypes.map((ft) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () => _addNewField(ft['type'] as String, ft['label'] as String),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Icon(ft['icon'] as IconData, size: 18, color: const Color(0xFF2563EB)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ft['label'] as String, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                                  Text(ft['desc'] as String, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                                ],
                              ),
                            ),
                            const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(width: 24),
          const SizedBox(height: 600, child: VerticalDivider(width: 1, color: Color(0xFFE2E8F0))),
          const SizedBox(width: 24),

          // Right Canvas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('FORM CANVAS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5)),
                    const Spacer(),
                    Text('${_activeFields.length} Custom Fields configured', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 14),

                ReorderableListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _activeFields.length,
                  onReorder: (oldIdx, newIdx) {
                    setState(() {
                      if (newIdx > oldIdx) newIdx -= 1;
                      final item = _activeFields.removeAt(oldIdx);
                      _activeFields.insert(newIdx, item);
                    });
                    widget.onFieldsUpdated(_activeFields);
                  },
                  itemBuilder: (context, index) {
                    final f = _activeFields[index];
                    final hasOptions = f.fieldType == 'dropDown' || f.fieldType == 'radioGroup' || f.fieldType == 'checkBoxGroup';

                    return Container(
                      key: ValueKey(f.id),
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                        boxShadow: const [BoxShadow(color: Color(0x03000000), blurRadius: 4)],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.drag_indicator_rounded, size: 18, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 8),
                          // Type badge
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                            child: Text(f.fieldType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ),
                          const SizedBox(width: 12),
                          // Editable Label
                          Expanded(
                            child: TextFormField(
                              initialValue: f.label,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: const InputDecoration(isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6), border: OutlineInputBorder()),
                              onChanged: (val) {
                                _activeFields[index] = f.copyWith(label: val);
                                widget.onFieldsUpdated(_activeFields);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Required toggle
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Checkbox(
                                value: f.isRequired,
                                activeColor: const Color(0xFFF59E0B),
                                onChanged: (val) {
                                  setState(() {
                                    _activeFields[index] = f.copyWith(isRequired: val ?? false);
                                  });
                                  widget.onFieldsUpdated(_activeFields);
                                },
                              ),
                              const Text('Required', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                            ],
                          ),
                          if (hasOptions) ...[
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: () => _showEditOptionsDialog(index),
                              icon: const Icon(Icons.list_alt_rounded, size: 14),
                              label: Text('${f.options.length} Choices', style: const TextStyle(fontSize: 11.5)),
                              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4)),
                            ),
                          ],
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Color(0xFFEF4444)),
                            onPressed: () => _removeField(index),
                            tooltip: 'Delete field',
                          ),
                        ],
                      ),
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

  // Preview Pane (renders live form inputs)
  Widget _buildPreviewPane() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: const [
                Icon(Icons.phone_android_rounded, color: Color(0xFFD97706), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text('This preview demonstrates how dynamic fields will appear in the Telecaller Mobile App & Web Disposition modal.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: _activeFields.map((f) {
              return SizedBox(
                width: 380,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                        children: [
                          TextSpan(text: f.label),
                          if (f.isRequired) const TextSpan(text: ' *', style: TextStyle(color: Color(0xFFEF4444))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    _renderFieldWidget(f),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _renderFieldWidget(FormFieldSettingModel f) {
    switch (f.fieldType) {
      case 'numericField':
        return const TextField(keyboardType: TextInputType.number, decoration: InputDecoration(border: OutlineInputBorder(), hintText: '0.00', contentPadding: EdgeInsets.all(10)));
      case 'emailField':
        return const TextField(keyboardType: TextInputType.emailAddress, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'example@company.com', contentPadding: EdgeInsets.all(10)));
      case 'websiteField':
        return const TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'https://...', contentPadding: EdgeInsets.all(10)));
      case 'textArea':
        return const TextField(maxLines: 3, decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Write notes here...', contentPadding: EdgeInsets.all(10)));
      case 'dropDown':
        return DropdownButtonFormField<String>(
          initialValue: f.options.isNotEmpty ? f.options.first : null,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
          items: f.options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 12.5)))).toList(),
          onChanged: (_) {},
        );
      case 'radioGroup':
        return Column(
          children: f.options.map((opt) => RadioListTile<String>(title: Text(opt, style: const TextStyle(fontSize: 12)), value: opt, groupValue: f.options.first, activeColor: const Color(0xFFF59E0B), dense: true, contentPadding: EdgeInsets.zero, onChanged: (_) {})).toList(),
        );
      case 'checkBoxGroup':
        return Column(
          children: f.options.map((opt) => CheckboxListTile(title: Text(opt, style: const TextStyle(fontSize: 12)), value: false, activeColor: const Color(0xFFF59E0B), dense: true, contentPadding: EdgeInsets.zero, onChanged: (_) {})).toList(),
        );
      case 'datePicker':
        return const TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Select Target Date 📅', contentPadding: EdgeInsets.all(10)));
      default:
        return const TextField(decoration: InputDecoration(border: OutlineInputBorder(), hintText: 'Enter text...', contentPadding: EdgeInsets.all(10)));
    }
  }
}
