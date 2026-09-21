import 'package:flutter/material.dart';

class AddExcludePhoneDialog extends StatefulWidget {
  final List<Map<String, dynamic>> employeeRoster;
  final Function(List<Map<String, dynamic>> newItems) onAddNumbers;

  const AddExcludePhoneDialog({
    super.key,
    required this.employeeRoster,
    required this.onAddNumbers,
  });

  @override
  State<AddExcludePhoneDialog> createState() => _AddExcludePhoneDialogState();
}

class _AddExcludePhoneDialogState extends State<AddExcludePhoneDialog> {
  // Left Column State: Select From Employees
  bool _addAllEmployees = false;
  final Set<int> _selectedEmployeeIds = {};
  String? _dropdownSelectedName;

  // Right Column State: Add New Contact
  final TextEditingController _contactNameCtrl = TextEditingController();
  final TextEditingController _contactNumberCtrl = TextEditingController();
  bool _hasNumberText = false;

  @override
  void initState() {
    super.initState();
    _contactNumberCtrl.addListener(() {
      final hasText = _contactNumberCtrl.text.trim().isNotEmpty;
      if (hasText != _hasNumberText) {
        setState(() => _hasNumberText = hasText);
      }
    });
  }

  @override
  void dispose() {
    _contactNameCtrl.dispose();
    _contactNumberCtrl.dispose();
    super.dispose();
  }

  void _onRadioChanged(bool addAll) {
    setState(() {
      _addAllEmployees = addAll;
      if (addAll) {
        _selectedEmployeeIds.clear();
        for (final emp in widget.employeeRoster) {
          _selectedEmployeeIds.add(emp['id'] as int);
        }
      } else {
        _selectedEmployeeIds.clear();
      }
    });
  }

  void _handleAddSelectedEmployees() {
    if (_selectedEmployeeIds.isEmpty) return;

    final List<Map<String, dynamic>> toAdd = [];
    for (final emp in widget.employeeRoster) {
      if (_selectedEmployeeIds.contains(emp['id'])) {
        toAdd.add({
          'id': DateTime.now().millisecondsSinceEpoch + (emp['id'] as int),
          'contactName': emp['name']?.toString() ?? 'Employee',
          'contactNumber': emp['phone']?.toString() ?? '',
        });
      }
    }

    widget.onAddNumbers(toAdd);
    Navigator.of(context).pop();
  }

  void _handleAddNewContact() {
    final phone = _contactNumberCtrl.text.trim();
    if (phone.isEmpty) return;

    final name = _contactNameCtrl.text.trim();
    final newEntry = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'contactName': name.isEmpty ? 'Excluded Contact' : name,
      'contactNumber': phone,
    };

    widget.onAddNumbers([newEntry]);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedEmployeeIds.length;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Center(
        child: Container(
          width: 860,
          height: 485,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Dialog Header: Centered title with 'x' close button on top-right
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 16, 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Add Exclude Phone Number',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: const Padding(
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.close_rounded,
                            size: 20,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Dialog Body: Two columns with "OR" divider
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // LEFT COLUMN: Select From Employees
                    Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(28, 20, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Column Heading
                              const Text(
                                'Select From Employees',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Radio Buttons: Add All Employees | Search & Add
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  InkWell(
                                    onTap: () => _onRadioChanged(true),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 17,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: _addAllEmployees ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                              width: _addAllEmployees ? 5.0 : 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Add All Employees',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  InkWell(
                                    onTap: () => _onRadioChanged(false),
                                    borderRadius: BorderRadius.circular(4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 17,
                                          height: 17,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: !_addAllEmployees ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                                              width: !_addAllEmployees ? 5.0 : 1.5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        const Text(
                                          'Search & Add',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF334155),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Dropdown Select Field
                              Container(
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFFCBD5E1)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    isExpanded: true,
                                    value: _dropdownSelectedName,
                                    hint: Text(
                                      _addAllEmployees ? 'All Employees Selected' : 'Select',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _addAllEmployees ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.arrow_drop_down,
                                      color: Color(0xFF64748B),
                                    ),
                                    items: _addAllEmployees
                                        ? null
                                        : widget.employeeRoster.map((emp) {
                                            final name = emp['name']?.toString() ?? 'Employee';
                                            return DropdownMenuItem<String>(
                                              value: name,
                                              child: Text(
                                                '$name (${emp['phone']})',
                                                style: const TextStyle(fontSize: 13),
                                              ),
                                            );
                                          }).toList(),
                                    onChanged: _addAllEmployees
                                        ? null
                                        : (val) {
                                            if (val != null) {
                                              setState(() {
                                                _dropdownSelectedName = val;
                                                final match = widget.employeeRoster.firstWhere(
                                                  (e) => e['name'] == val,
                                                  orElse: () => {},
                                                );
                                                if (match.isNotEmpty) {
                                                  _selectedEmployeeIds.add(match['id'] as int);
                                                }
                                              });
                                            }
                                          },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Mini Table: Select | Name | Number
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: [
                                      // Table Header
                                      Container(
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
                                          border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 44,
                                              child: Checkbox(
                                                value: widget.employeeRoster.isNotEmpty &&
                                                    _selectedEmployeeIds.length == widget.employeeRoster.length,
                                                activeColor: const Color(0xFFF97316),
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                onChanged: (val) {
                                                  setState(() {
                                                    if (val == true) {
                                                      for (final e in widget.employeeRoster) {
                                                        _selectedEmployeeIds.add(e['id'] as int);
                                                      }
                                                    } else {
                                                      _selectedEmployeeIds.clear();
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                                            const Expanded(
                                              flex: 5,
                                              child: Center(
                                                child: Text(
                                                  'Name',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                                            const Expanded(
                                              flex: 6,
                                              child: Center(
                                                child: Text(
                                                  'Number',
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF1E293B),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Table Rows
                                      Expanded(
                                        child: widget.employeeRoster.isEmpty
                                            ? const Center(
                                                child: Text(
                                                  'No employees found',
                                                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                                ),
                                              )
                                            : ListView.separated(
                                                padding: EdgeInsets.zero,
                                                itemCount: widget.employeeRoster.length,
                                                separatorBuilder: (context, index) =>
                                                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                                                itemBuilder: (context, i) {
                                                  final emp = widget.employeeRoster[i];
                                                  final empId = emp['id'] as int;
                                                  final isChecked = _selectedEmployeeIds.contains(empId);

                                                  return InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (isChecked) {
                                                          _selectedEmployeeIds.remove(empId);
                                                        } else {
                                                          _selectedEmployeeIds.add(empId);
                                                        }
                                                      });
                                                    },
                                                    child: SizedBox(
                                                      height: 38,
                                                      child: Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 44,
                                                            child: Checkbox(
                                                              value: isChecked,
                                                              activeColor: const Color(0xFFF97316),
                                                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                              onChanged: (val) {
                                                                setState(() {
                                                                  if (val == true) {
                                                                    _selectedEmployeeIds.add(empId);
                                                                  } else {
                                                                    _selectedEmployeeIds.remove(empId);
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                          ),
                                                          const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                                                          Expanded(
                                                            flex: 5,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                              child: Text(
                                                                emp['name']?.toString() ?? '',
                                                                style: const TextStyle(
                                                                  fontSize: 12.5,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Color(0xFF334155),
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                          const VerticalDivider(width: 1, color: Color(0xFFE2E8F0)),
                                                          Expanded(
                                                            flex: 6,
                                                            child: Padding(
                                                              padding: const EdgeInsets.symmetric(horizontal: 10),
                                                              child: Text(
                                                                emp['phone']?.toString() ?? '',
                                                                style: const TextStyle(
                                                                  fontSize: 12,
                                                                  color: Color(0xFF475569),
                                                                ),
                                                                maxLines: 1,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Orange Button: Add (N)
                              ElevatedButton(
                                onPressed: selectedCount > 0 ? _handleAddSelectedEmployees : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  disabledBackgroundColor: const Color(0xFFFDBA74),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  selectedCount > 0 ? 'Add ($selectedCount)' : 'Add',
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // CENTER DIVIDER WITH "OR" BADGE
                      SizedBox(
                        width: 44,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const VerticalDivider(
                              width: 1,
                              thickness: 1,
                              color: Color(0xFFE2E8F0),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Text(
                                'OR',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // RIGHT COLUMN: Add New Contact
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 20, 28, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Column Heading
                              const Center(
                                child: Text(
                                  'Add New Contact',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF334155),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),

                              // Field 1: Contact Name
                              const Text(
                                'Contact Name',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _contactNameCtrl,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  decoration: InputDecoration(
                                    hintText: 'Contact Name',
                                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.4),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Field 2: Contact Number *
                              RichText(
                                text: const TextSpan(
                                  text: 'Contact Number ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF475569),
                                  ),
                                  children: [
                                    TextSpan(
                                      text: '*',
                                      style: TextStyle(
                                        color: Color(0xFFEF4444),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                child: TextField(
                                  controller: _contactNumberCtrl,
                                  keyboardType: TextInputType.phone,
                                  style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                  decoration: InputDecoration(
                                    hintText: 'Contact Number',
                                    hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    filled: true,
                                    fillColor: Colors.white,
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
                                      borderSide: const BorderSide(color: Color(0xFFF97316), width: 1.4),
                                    ),
                                  ),
                                  onSubmitted: (_) => _handleAddNewContact(),
                                ),
                              ),
                              const Spacer(),

                              // Bottom Add Button (Soft orange when empty, solid orange when active)
                              ElevatedButton(
                                onPressed: _hasNumberText ? _handleAddNewContact : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFF97316),
                                  disabledBackgroundColor: const Color(0xFFFDBA74),
                                  foregroundColor: Colors.white,
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 11),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Add',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
          ),
        ),
      ),
    );
  }
}
