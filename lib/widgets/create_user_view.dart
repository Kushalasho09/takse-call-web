import 'package:flutter/material.dart';

class CreateUserView extends StatefulWidget {
  final List<Map<String, dynamic>> employeeRoster;
  final VoidCallback onBack;
  final Function(Map<String, dynamic> newUser) onUserCreated;
  final Map<String, dynamic>? initialUser;

  const CreateUserView({
    super.key,
    required this.employeeRoster,
    required this.onBack,
    required this.onUserCreated,
    this.initialUser,
  });

  @override
  State<CreateUserView> createState() => _CreateUserViewState();
}

class _CreateUserViewState extends State<CreateUserView> {
  int _currentStep = 1; // 1: Basic Info, 2: Select Employees, 3: Set Permission, 4: Summary

  // Step 1 State: Basic Info
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  String _countryCode = '+91';
  bool _setPasswordYes = false;

  // Step 2 State: Select Employees
  // 'all', 'tags', 'specific'
  String _accessScope = 'all';
  final Set<String> _selectedTags = {};
  final Set<int> _selectedEmployeeIds = {};

  final List<String> _availableTags = ['Sales', 'Support', 'Field Agent', 'VIP Lead', 'Management'];

  // Step 3 State: Set Permission
  // Structure: Map<String (featureKey), Map<'manage'|'view'|'export', bool>>
  final Map<String, Map<String, bool>> _permissions = {};

  // Permission modules definition matching Image 4
  final Map<String, List<Map<String, dynamic>>> _featureModules = {
    'Manage': [
      {'key': 'employees', 'name': 'Employees', 'canManage': true, 'canView': true, 'canExport': true},
      {'key': 'exclude_phone_numbers', 'name': 'Exclude Phone Number', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'users', 'name': 'Users', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'call_recordings', 'name': 'Call Recordings', 'canManage': true, 'canView': true, 'canExport': true},
      {'key': 'call_transcripts', 'name': 'Call Transcript & Analysis', 'canManage': true, 'canView': true, 'canExport': true},
      {'key': 'call_note_templates', 'name': 'Call Note Templates', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'message_templates', 'name': 'Message Templates', 'canManage': true, 'canView': true, 'canExport': false},
    ],
    'Leads': [
      {'key': 'my_leads', 'name': 'My Leads', 'canManage': true, 'canView': true, 'canExport': true},
      {'key': 'lead_reports', 'name': 'Lead Reports', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'status_report', 'name': 'Status Report', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'lead_not_contacted', 'name': 'Lead Not Contacted', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'status_change_report', 'name': 'Status Change Report', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'lead_overview_report', 'name': 'Lead Overview Report', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'lead_tags', 'name': 'Lead Tags', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'lead_status', 'name': 'Lead Status', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'form_settings', 'name': 'Form Settings', 'canManage': true, 'canView': false, 'canExport': false},
    ],
    'Reports': [
      {'key': 'periodic_report', 'name': 'Periodic Report', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'never_attended', 'name': 'Never Attended', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'not_pickup_by_client', 'name': 'Not Pickup by Client', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'employee_report', 'name': 'Employee Report', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'client_report', 'name': 'Client Report', 'canManage': false, 'canView': true, 'canExport': true},
    ],
    'Connectors': [
      {'key': 'purchased_connectors', 'name': 'Purchased', 'canManage': true, 'canView': true, 'canExport': true},
      {'key': 'available_connectors', 'name': 'Available', 'canManage': true, 'canView': true, 'canExport': false},
    ],
    'Settings': [
      {'key': 'tax_invoice', 'name': 'Tax Invoice', 'canManage': false, 'canView': true, 'canExport': true},
      {'key': 'my_settings', 'name': 'My Settings', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'general_settings', 'name': 'General Settings', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'biz_app_settings', 'name': 'Biz App Settings', 'canManage': true, 'canView': true, 'canExport': false},
      {'key': 'email_notification', 'name': 'Email Notification', 'canManage': true, 'canView': true, 'canExport': false},
    ],
    'Other': [
      {'key': 'edit_call_note', 'name': 'Edit Call Note', 'canManage': true, 'canView': true, 'canExport': false},
    ],
  };

  @override
  void initState() {
    super.initState();
    // Initialize permissions
    _initPermissions();

    if (widget.initialUser != null) {
      final u = widget.initialUser!;
      _nameCtrl.text = u['name'] ?? '';
      _emailCtrl.text = u['email'] ?? '';
      final rawPhone = (u['phone'] ?? '').toString();
      if (rawPhone.startsWith('+91')) {
        _countryCode = '+91';
        _phoneCtrl.text = rawPhone.replaceFirst('+91', '').replaceAll('-', '').trim();
      } else {
        _phoneCtrl.text = rawPhone;
      }
      _accessScope = u['accessScope'] ?? 'all';
    }
  }

  void _initPermissions() {
    for (final entry in _featureModules.entries) {
      for (final feature in entry.value) {
        final key = feature['key'] as String;
        _permissions[key] = {
          'manage': false,
          'view': false,
          'export': false,
        };
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  bool _isStep1Valid() {
    return _nameCtrl.text.trim().isNotEmpty &&
        _phoneCtrl.text.trim().isNotEmpty &&
        _emailCtrl.text.trim().isNotEmpty;
  }

  void _toggleModuleAll(String moduleTitle, bool enable) {
    setState(() {
      final features = _featureModules[moduleTitle] ?? [];
      for (final f in features) {
        final key = f['key'] as String;
        if (f['canManage'] == true) _permissions[key]!['manage'] = enable;
        if (f['canView'] == true) _permissions[key]!['view'] = enable;
        if (f['canExport'] == true) _permissions[key]!['export'] = enable;
      }
    });
  }

  void _handleSubmit() {
    final name = _nameCtrl.text.trim();
    final phone = '$_countryCode-${_phoneCtrl.text.trim()}';
    final email = _emailCtrl.text.trim();

    final newUser = {
      'id': widget.initialUser?['id'] ?? DateTime.now().millisecondsSinceEpoch,
      'name': name,
      'phone': phone,
      'email': email,
      'accessScope': _accessScope,
      'selectedTags': _selectedTags.toList(),
      'selectedEmployeeIds': _selectedEmployeeIds.toList(),
      'permissions': Map<String, Map<String, bool>>.from(_permissions),
      'isTrashed': false,
      'createdAt': widget.initialUser?['createdAt'] ?? 'Today',
    };

    widget.onUserCreated(newUser);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Header Bar: Create User Title
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Create User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                  onPressed: widget.onBack,
                  splashRadius: 18,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 4-Step Stepper Bar (Matches Images 2, 3, 4, 5 Pixel-Perfect)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
            child: Row(
              children: [
                _buildStepperItem(
                  stepNumber: 1,
                  title: 'Basic Info',
                  icon: Icons.person_outline_rounded,
                  isActive: _currentStep == 1,
                  isCompleted: _currentStep > 1,
                ),
                _buildStepConnector(isCompleted: _currentStep > 1),
                _buildStepperItem(
                  stepNumber: 2,
                  title: 'Select Employees',
                  icon: Icons.groups_outlined,
                  isActive: _currentStep == 2,
                  isCompleted: _currentStep > 2,
                ),
                _buildStepConnector(isCompleted: _currentStep > 2),
                _buildStepperItem(
                  stepNumber: 3,
                  title: 'Set Permission',
                  icon: Icons.tune_rounded,
                  isActive: _currentStep == 3,
                  isCompleted: _currentStep > 3,
                ),
                _buildStepConnector(isCompleted: _currentStep > 3),
                _buildStepperItem(
                  stepNumber: 4,
                  title: 'Summary',
                  icon: Icons.description_outlined,
                  isActive: _currentStep == 4,
                  isCompleted: false,
                ),
              ],
            ),
          ),

          // Active Step Body
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: _buildActiveStep(),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? const Color(0xFFF97316) : const Color(0xFFE2E8F0),
        margin: const EdgeInsets.only(bottom: 24),
      ),
    );
  }

  Widget _buildStepperItem({
    required int stepNumber,
    required String title,
    required IconData icon,
    required bool isActive,
    required bool isCompleted,
  }) {
    Color circleBg = Colors.white;
    Color borderColor = const Color(0xFFCBD5E1);
    Color iconColor = const Color(0xFF64748B);

    if (isActive) {
      circleBg = const Color(0xFF1E293B);
      borderColor = const Color(0xFFF97316);
      iconColor = Colors.white;
    } else if (isCompleted) {
      circleBg = const Color(0xFFFFF7ED);
      borderColor = const Color(0xFFF97316);
      iconColor = const Color(0xFFF97316);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step $stepNumber',
          style: TextStyle(
            fontSize: 11,
            color: isActive ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: circleBg,
            shape: BoxShape.circle,
            border: Border.all(
              color: borderColor,
              width: isActive ? 2.5 : 1.5,
            ),
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : icon,
              size: 22,
              color: iconColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1BasicInfo();
      case 2:
        return _buildStep2SelectEmployees();
      case 3:
        return _buildStep3SetPermission();
      case 4:
        return _buildStep4Summary();
      default:
        return _buildStep1BasicInfo();
    }
  }

  // STEP 1: Basic Info (Image 2)
  Widget _buildStep1BasicInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left Column: Name, Mobile Number, Email
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Field 1: Name *
                  _buildFieldLabel('Name', true),
                  const SizedBox(height: 6),
                  _buildTextInput(_nameCtrl, 'Name'),
                  const SizedBox(height: 18),

                  // Field 2: Mobile Number *
                  _buildFieldLabel('Mobile Number', true),
                  const SizedBox(height: 6),
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: const BoxDecoration(
                            border: Border(right: BorderSide(color: Color(0xFFCBD5E1))),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(_countryCode, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                              const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                            onChanged: (_) => setState(() {}),
                            decoration: const InputDecoration(
                              hintText: '74104 10123',
                              hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12),
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Field 3: Email *
                  _buildFieldLabel('Email', true),
                  const SizedBox(height: 6),
                  _buildTextInput(_emailCtrl, 'Email', keyboardType: TextInputType.emailAddress),
                ],
              ),
            ),
            const SizedBox(width: 48),

            // Right Column: Set Password
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Set Password',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF334155),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Radio: No / Yes
                  Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _setPasswordYes = false),
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
                                  color: !_setPasswordYes ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                  width: !_setPasswordYes ? 5.0 : 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('No', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      InkWell(
                        onTap: () => setState(() => _setPasswordYes = true),
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
                                  color: _setPasswordYes ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                                  width: _setPasswordYes ? 5.0 : 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('Yes', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF334155))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Info message or Password fields
                  if (!_setPasswordYes)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 15, color: Colors.orange.shade700),
                        const SizedBox(width: 6),
                        const Expanded(
                          child: Text(
                            'An email will be sent to verify and set password',
                            style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _buildFieldLabel('Password', true),
                    const SizedBox(height: 6),
                    _buildTextInput(_passwordCtrl, 'Enter password', obscureText: true),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Confirm Password', true),
                    const SizedBox(height: 6),
                    _buildTextInput(_confirmPasswordCtrl, 'Confirm password', obscureText: true),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 36),

        // Footer buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: widget.onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('Cancel', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            ElevatedButton(
              onPressed: _isStep1Valid() ? () => setState(() => _currentStep = 2) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                disabledBackgroundColor: const Color(0xFFFDBA74),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 2: Select Employees (Image 3)
  Widget _buildStep2SelectEmployees() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Allow Access to: All Employees | Specific Employees Tag(s) | Specific Employee(s)
        Row(
          children: [
            const Text(
              'Allow Access to: ',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
            ),
            const SizedBox(width: 10),
            _buildAccessRadio('all', 'All Employees'),
            const SizedBox(width: 20),
            _buildAccessRadio('tags', 'Specific Employees Tag(s)'),
            const SizedBox(width: 20),
            _buildAccessRadio('specific', 'Specific Employee(s)'),
          ],
        ),
        const SizedBox(height: 18),

        // Scope description or selector
        if (_accessScope == 'all')
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2FE),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFBAE6FD)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF0284C7), size: 18),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Whenever any employee is added or removed the user will notice the effect automatically.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF0369A1), fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        else if (_accessScope == 'tags') ...[
          const Text('Select Employee Tags:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                selected: isSelected,
                label: Text(tag),
                selectedColor: const Color(0xFFFFF7ED),
                checkmarkColor: const Color(0xFFF97316),
                side: BorderSide(color: isSelected ? const Color(0xFFF97316) : const Color(0xFFCBD5E1)),
                labelStyle: TextStyle(
                  color: isSelected ? const Color(0xFFF97316) : const Color(0xFF475569),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12.5,
                ),
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ] else ...[
          const Text('Select Individual Employees:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
          const SizedBox(height: 10),
          Container(
            height: 160,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE2E8F0)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListView.separated(
              itemCount: widget.employeeRoster.length,
              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFE2E8F0)),
              itemBuilder: (context, idx) {
                final emp = widget.employeeRoster[idx];
                final id = emp['id'] as int;
                final isSelected = _selectedEmployeeIds.contains(id);
                return CheckboxListTile(
                  value: isSelected,
                  activeColor: const Color(0xFFF97316),
                  title: Text(emp['name'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(emp['phone'] ?? '', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedEmployeeIds.add(id);
                      } else {
                        _selectedEmployeeIds.remove(id);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 36),

        // Footer buttons: Back & Next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 1),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF97316),
                side: const BorderSide(color: Color(0xFFF97316)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 3),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccessRadio(String value, String label) {
    final isSelected = _accessScope == value;
    return InkWell(
      onTap: () => setState(() => _accessScope = value),
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
                color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                width: isSelected ? 5.0 : 1.5,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: Set Permission (Image 4)
  Widget _buildStep3SetPermission() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Permission Matrix Table
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Main Table Header
              Container(
                height: 42,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    Expanded(flex: 4, child: Text('Features', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                    Expanded(flex: 3, child: Center(child: Text('Can Manage\nAdd / Edit / Delete', textAlign: TextAlign.center, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                    Expanded(flex: 3, child: Center(child: Text('Can View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                    Expanded(flex: 3, child: Center(child: Text('Can Export', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Modules List
              for (final entry in _featureModules.entries) ...[
                // Module Yellow Category Bar
                Container(
                  color: const Color(0xFFFEF9C3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _toggleModuleAll(entry.key, true),
                            child: const Text('Select All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                          ),
                          const Text(' | ', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                          InkWell(
                            onTap: () => _toggleModuleAll(entry.key, false),
                            child: const Text('Unselect All', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFFDC2626))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                // Feature Rows in Category
                for (final feature in entry.value) ...[
                  _buildPermissionRow(feature),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Footer buttons: Back & Next
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            OutlinedButton(
              onPressed: () => setState(() => _currentStep = 2),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFF97316),
                side: const BorderSide(color: Color(0xFFF97316)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Back', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 4),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Next', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPermissionRow(Map<String, dynamic> feature) {
    final key = feature['key'] as String;
    final name = feature['name'] as String;
    final canManage = feature['canManage'] == true;
    final canView = feature['canView'] == true;
    final canExport = feature['canExport'] == true;

    final pMap = _permissions[key] ?? {'manage': false, 'view': false, 'export': false};

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              name,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: Color(0xFF334155)),
            ),
          ),
          // Can Manage Switch
          Expanded(
            flex: 3,
            child: canManage
                ? Center(
                    child: _buildPermissionToggle(
                      value: pMap['manage'] ?? false,
                      onChanged: (val) => setState(() => pMap['manage'] = val),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Can View Switch
          Expanded(
            flex: 3,
            child: canView
                ? Center(
                    child: _buildPermissionToggle(
                      value: pMap['view'] ?? false,
                      onChanged: (val) => setState(() => pMap['view'] = val),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Can Export Switch
          Expanded(
            flex: 3,
            child: canExport
                ? Center(
                    child: _buildPermissionToggle(
                      value: pMap['export'] ?? false,
                      onChanged: (val) => setState(() => pMap['export'] = val),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionToggle({required bool value, required ValueChanged<bool> onChanged}) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 18,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: value ? const Color(0xFFF97316) : const Color(0xFFCBD5E1),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 150),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.all(1),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value ? 'Yes' : 'No',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: value ? const Color(0xFFF97316) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: Summary (Image 5)
  Widget _buildStep4Summary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Basic Information
        _buildSummaryCardHeader('Basic Information', onEdit: () => setState(() => _currentStep = 1)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _summaryField('Name', _nameCtrl.text),
                  const SizedBox(width: 48),
                  _summaryField('Mobile No', '$_countryCode-${_phoneCtrl.text}'),
                  const SizedBox(width: 48),
                  _summaryField('E-mail Id', _emailCtrl.text),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 15, color: Color(0xFF0284C7)),
                    SizedBox(width: 6),
                    Text(
                      'System will send an email to verify the account and set the password.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF0369A1)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Section 2: Selected Employees
        _buildSummaryCardHeader('Selected Employees', onEdit: () => setState(() => _currentStep = 2)),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E8F0)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            _accessScope == 'all'
                ? 'Allow access to all the employee(s)'
                : _accessScope == 'tags'
                    ? 'Allow access to employees with tags: ${_selectedTags.join(', ')}'
                    : 'Allow access to ${_selectedEmployeeIds.length} specific employee(s)',
            style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 24),

        // Section 3: Set Permission
        _buildSummaryCardHeader('Set Permission', onEdit: () => setState(() => _currentStep = 3)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            children: [
              // Summary table header
              Container(
                height: 38,
                color: const Color(0xFFF8FAFC),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    Expanded(flex: 4, child: Text('Features', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF334155)))),
                    Expanded(flex: 3, child: Center(child: Text('Can Manage\nAdd / Edit / Delete', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                    Expanded(flex: 3, child: Center(child: Text('Can View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                    Expanded(flex: 3, child: Center(child: Text('Can Export', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF334155))))),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              for (final entry in _featureModules.entries) ...[
                // Yellow Category Header
                Container(
                  width: double.infinity,
                  color: const Color(0xFFFEF9C3),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Text(
                    entry.key,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),

                for (final f in entry.value) ...[
                  _buildSummaryPermissionRow(f),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: 36),

        // Footer buttons: CANCEL & SUBMIT (Image 5)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.onBack,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E293B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('CANCEL', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: 14),
            ElevatedButton(
              onPressed: _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                elevation: 0,
              ),
              child: const Text('SUBMIT', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCardHeader(String title, {required VoidCallback onEdit}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          InkWell(
            onTap: onEdit,
            child: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _summaryField(String label, String value) {
    return RichText(
      text: TextSpan(
        text: '$label : ',
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        children: [
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.normal, color: Color(0xFF475569)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPermissionRow(Map<String, dynamic> feature) {
    final key = feature['key'] as String;
    final name = feature['name'] as String;
    final canManage = feature['canManage'] == true;
    final canView = feature['canView'] == true;
    final canExport = feature['canExport'] == true;

    final pMap = _permissions[key] ?? {'manage': false, 'view': false, 'export': false};

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(name, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          ),
          Expanded(
            flex: 3,
            child: canManage
                ? Center(
                    child: Text(
                      (pMap['manage'] ?? false) ? 'YES' : 'NO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (pMap['manage'] ?? false) ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 3,
            child: canView
                ? Center(
                    child: Text(
                      (pMap['view'] ?? false) ? 'YES' : 'NO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (pMap['view'] ?? false) ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            flex: 3,
            child: canExport
                ? Center(
                    child: Text(
                      (pMap['export'] ?? false) ? 'YES' : 'NO',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (pMap['export'] ?? false) ? const Color(0xFF10B981) : const Color(0xFF64748B),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String text, bool isMandatory) {
    return RichText(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFF475569),
        ),
        children: [
          if (isMandatory)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildTextInput(
    TextEditingController controller,
    String hint, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hint,
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
    );
  }
}
