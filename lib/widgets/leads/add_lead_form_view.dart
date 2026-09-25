import 'package:flutter/material.dart';
import '../../models/lead_item.dart';

class AddLeadFormView extends StatefulWidget {
  final VoidCallback onCancel;
  final ValueChanged<LeadItem> onLeadAdded;

  const AddLeadFormView({
    super.key,
    required this.onCancel,
    required this.onLeadAdded,
  });

  @override
  State<AddLeadFormView> createState() => _AddLeadFormViewState();
}

class _AddLeadFormViewState extends State<AddLeadFormView> {
  final _formKey = GlobalKey<FormState>();

  // Form Controllers
  final TextEditingController _firstNameCtrl = TextEditingController();
  final TextEditingController _lastNameCtrl = TextEditingController();
  final TextEditingController _phoneCtrl = TextEditingController();
  final TextEditingController _altPhoneCtrl = TextEditingController();
  final TextEditingController _tagsCtrl = TextEditingController();
  final TextEditingController _companyCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _address1Ctrl = TextEditingController();
  final TextEditingController _address2Ctrl = TextEditingController();
  final TextEditingController _cityCtrl = TextEditingController();
  final TextEditingController _stateCtrl = TextEditingController();
  final TextEditingController _zipcodeCtrl = TextEditingController();
  final TextEditingController _countryCtrl = TextEditingController(text: 'India');
  final TextEditingController _descCtrl = TextEditingController();
  final TextEditingController _sourceCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();

  String _phoneCountryCode = '+91';
  String _altPhoneCountryCode = '+91';

  String? _selectedStatus;
  final List<String> _statusOptions = [
    'Positive',
    'Follow Up',
    'Contacted',
    'Interested',
    'Not Interested',
    'Demo Scheduled',
    'Closed - Won',
    'Closed - Lost',
    'Junk',
  ];

  bool _assignToSpecificEmployee = true;
  String _selectedEmployee = 'kushal asodia (+91-9664579043)';
  final List<String> _employeeList = [
    'kushal asodia (+91-9664579043)',
    'Rohan Sharma (+91-9876543210)',
    'Amit Patel (+91-9822334455)',
    'Priya Verma (+91-9712345678)',
  ];

  bool _mapAvailableCallLogs = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _altPhoneCtrl.dispose();
    _tagsCtrl.dispose();
    _companyCtrl.dispose();
    _emailCtrl.dispose();
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _zipcodeCtrl.dispose();
    _countryCtrl.dispose();
    _descCtrl.dispose();
    _sourceCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final firstName = _firstNameCtrl.text.trim();
      final lastName = _lastNameCtrl.text.trim();
      final fullName = lastName.isNotEmpty ? '$firstName $lastName' : firstName;

      final rawPhone = _phoneCtrl.text.trim();
      final fullPhone = '$_phoneCountryCode $rawPhone';

      final tags = _tagsCtrl.text
          .split(RegExp(r'[,;\n]'))
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList();
      if (tags.isEmpty) {
        tags.add('New');
      }

      final now = DateTime.now();
      final createdDateStr =
          '${now.day} ${_monthName(now.month)} ${now.year}, ${_formatTime(now)}';
      final todayStr = '${now.day} ${_monthName(now.month)} ${now.year}';

      // Parse employee info
      String assignedName = 'kushal asodia';
      String assignedPhone = '+91-9664579043';
      if (_selectedEmployee.contains('(')) {
        final parts = _selectedEmployee.split('(');
        assignedName = parts[0].trim();
        assignedPhone = parts[1].replaceAll(')', '').trim();
      }

      final newLead = LeadItem(
        id: 'lead_${DateTime.now().millisecondsSinceEpoch}',
        srNo: 1, // Will be re-indexed in list
        name: fullName.toLowerCase(),
        phone: fullPhone,
        altPhone: _altPhoneCtrl.text.trim().isNotEmpty
            ? '$_altPhoneCountryCode ${_altPhoneCtrl.text.trim()}'
            : null,
        createdDate: createdDateStr,
        attempts: 0,
        tags: tags,
        tagAssignedDate: todayStr,
        assignedTo: assignedName,
        assignedToPhone: assignedPhone,
        assignedDate: '$todayStr | ${_formatTime(now)}',
        status: _selectedStatus ?? 'Positive',
        company: _companyCtrl.text.trim().isNotEmpty ? _companyCtrl.text.trim() : null,
        email: _emailCtrl.text.trim().isNotEmpty ? _emailCtrl.text.trim() : null,
        address1: _address1Ctrl.text.trim().isNotEmpty ? _address1Ctrl.text.trim() : null,
        address2: _address2Ctrl.text.trim().isNotEmpty ? _address2Ctrl.text.trim() : null,
        city: _cityCtrl.text.trim().isNotEmpty ? _cityCtrl.text.trim() : null,
        state: _stateCtrl.text.trim().isNotEmpty ? _stateCtrl.text.trim() : null,
        zipcode: _zipcodeCtrl.text.trim().isNotEmpty ? _zipcodeCtrl.text.trim() : null,
        country: _countryCtrl.text.trim().isNotEmpty ? _countryCtrl.text.trim() : 'India',
        description: _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
        source: _sourceCtrl.text.trim().isNotEmpty ? _sourceCtrl.text.trim() : null,
        price: _priceCtrl.text.trim().isNotEmpty ? _priceCtrl.text.trim() : null,
        mapCallLogs: _mapAvailableCallLogs,
      );

      widget.onLeadAdded(newLead);
    }
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0 ? 12 : (time.hour > 12 ? time.hour - 12 : time.hour);
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar matching Screenshot 2
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              child: Row(
                children: [
                  const Text(
                    'Add lead',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                    onPressed: widget.onCancel,
                    tooltip: 'Cancel',
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),

            // Form Fields Layout in 3 Columns
            Padding(
              padding: const EdgeInsets.all(24),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 900;
                  final isMedium = constraints.maxWidth > 600 && !isWide;

                  if (isWide) {
                    return _buildThreeColumnLayout();
                  } else if (isMedium) {
                    return _buildTwoColumnLayout();
                  } else {
                    return _buildSingleColumnLayout();
                  }
                },
              ),
            ),

            const SizedBox(height: 8),

            // Call Log Mapping Checkbox & Info alert
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _mapAvailableCallLogs,
                          activeColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          onChanged: (val) => setState(() => _mapAvailableCallLogs = val ?? true),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Map available call log of lead',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(top: 2, left: 4),
                        child: Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFFF59E0B)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "System will check all the existing call log and if any call matches with lead's numbers then it will be mapped.",
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action Buttons (Add, Cancel)
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Add',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: widget.onCancel,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF334155),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildThreeColumnLayout() {
    return Column(
      children: [
        // Row 1: First Name *, Last Name, Phone Number *
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTextField(label: 'First Name', isRequired: true, controller: _firstNameCtrl, hint: 'First Name')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Last Name', controller: _lastNameCtrl, hint: 'Last Name')),
            const SizedBox(width: 16),
            Expanded(child: _buildPhoneField(label: 'Phone Number', isRequired: true, controller: _phoneCtrl, countryCode: _phoneCountryCode, onCountryChanged: (c) => setState(() => _phoneCountryCode = c))),
          ],
        ),
        const SizedBox(height: 20),

        // Row 2: Alternate Phone Number, Tags, Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPhoneField(label: 'Alternate Phone Number', controller: _altPhoneCtrl, countryCode: _altPhoneCountryCode, onCountryChanged: (c) => setState(() => _altPhoneCountryCode = c))),
            const SizedBox(width: 16),
            Expanded(child: _buildTagsField()),
            const SizedBox(width: 16),
            Expanded(child: _buildStatusDropdown()),
          ],
        ),
        const SizedBox(height: 20),

        // Row 3: Assign Lead(s) to *, Company Name, Email
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAssignField()),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Company Name', controller: _companyCtrl, hint: 'Company Name')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Email', controller: _emailCtrl, hint: 'Email')),
          ],
        ),
        const SizedBox(height: 20),

        // Row 4: Address 1, Address 2, City
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTextField(label: 'Address 1', controller: _address1Ctrl, hint: 'Address 1')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Address 2', controller: _address2Ctrl, hint: 'Address 2')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'City', controller: _cityCtrl, hint: 'City')),
          ],
        ),
        const SizedBox(height: 20),

        // Row 5: State, Zipcode, Country
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTextField(label: 'State', controller: _stateCtrl, hint: 'State')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Zipcode', controller: _zipcodeCtrl, hint: 'Zipcode')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Country', controller: _countryCtrl, hint: 'Country')),
          ],
        ),
        const SizedBox(height: 20),

        // Row 6: Description, source, Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildTextField(label: 'Description', controller: _descCtrl, hint: 'Description')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'source', controller: _sourceCtrl, hint: 'source')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Price', controller: _priceCtrl, hint: 'Price')),
          ],
        ),
      ],
    );
  }

  Widget _buildTwoColumnLayout() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'First Name', isRequired: true, controller: _firstNameCtrl, hint: 'First Name')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Last Name', controller: _lastNameCtrl, hint: 'Last Name')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildPhoneField(label: 'Phone Number', isRequired: true, controller: _phoneCtrl, countryCode: _phoneCountryCode, onCountryChanged: (c) => setState(() => _phoneCountryCode = c))),
            const SizedBox(width: 16),
            Expanded(child: _buildPhoneField(label: 'Alternate Phone Number', controller: _altPhoneCtrl, countryCode: _altPhoneCountryCode, onCountryChanged: (c) => setState(() => _altPhoneCountryCode = c))),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTagsField()),
            const SizedBox(width: 16),
            Expanded(child: _buildStatusDropdown()),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildAssignField()),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Company Name', controller: _companyCtrl, hint: 'Company Name')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Email', controller: _emailCtrl, hint: 'Email')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'City', controller: _cityCtrl, hint: 'City')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Address 1', controller: _address1Ctrl, hint: 'Address 1')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Address 2', controller: _address2Ctrl, hint: 'Address 2')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'State', controller: _stateCtrl, hint: 'State')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Zipcode', controller: _zipcodeCtrl, hint: 'Zipcode')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Country', controller: _countryCtrl, hint: 'Country')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'source', controller: _sourceCtrl, hint: 'source')),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildTextField(label: 'Price', controller: _priceCtrl, hint: 'Price')),
            const SizedBox(width: 16),
            Expanded(child: _buildTextField(label: 'Description', controller: _descCtrl, hint: 'Description')),
          ],
        ),
      ],
    );
  }

  Widget _buildSingleColumnLayout() {
    return Column(
      children: [
        _buildTextField(label: 'First Name', isRequired: true, controller: _firstNameCtrl, hint: 'First Name'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Last Name', controller: _lastNameCtrl, hint: 'Last Name'),
        const SizedBox(height: 16),
        _buildPhoneField(label: 'Phone Number', isRequired: true, controller: _phoneCtrl, countryCode: _phoneCountryCode, onCountryChanged: (c) => setState(() => _phoneCountryCode = c)),
        const SizedBox(height: 16),
        _buildPhoneField(label: 'Alternate Phone Number', controller: _altPhoneCtrl, countryCode: _altPhoneCountryCode, onCountryChanged: (c) => setState(() => _altPhoneCountryCode = c)),
        const SizedBox(height: 16),
        _buildTagsField(),
        const SizedBox(height: 16),
        _buildStatusDropdown(),
        const SizedBox(height: 16),
        _buildAssignField(),
        const SizedBox(height: 16),
        _buildTextField(label: 'Company Name', controller: _companyCtrl, hint: 'Company Name'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Email', controller: _emailCtrl, hint: 'Email'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Address 1', controller: _address1Ctrl, hint: 'Address 1'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Address 2', controller: _address2Ctrl, hint: 'Address 2'),
        const SizedBox(height: 16),
        _buildTextField(label: 'City', controller: _cityCtrl, hint: 'City'),
        const SizedBox(height: 16),
        _buildTextField(label: 'State', controller: _stateCtrl, hint: 'State'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Zipcode', controller: _zipcodeCtrl, hint: 'Zipcode'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Country', controller: _countryCtrl, hint: 'Country'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Description', controller: _descCtrl, hint: 'Description'),
        const SizedBox(height: 16),
        _buildTextField(label: 'source', controller: _sourceCtrl, hint: 'source'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Price', controller: _priceCtrl, hint: 'Price'),
      ],
    );
  }

  Widget _buildFieldLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
            fontFamily: 'sans-serif',
          ),
          children: [
            TextSpan(text: label),
            if (isRequired)
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        TextFormField(
          controller: controller,
          validator: isRequired
              ? (val) => (val == null || val.trim().isEmpty) ? 'This field is required' : null
              : null,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneField({
    required String label,
    required TextEditingController controller,
    required String countryCode,
    required ValueChanged<String> onCountryChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(label, isRequired: isRequired),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country flag and prefix container
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(6)),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    countryCode,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF64748B)),
                ],
              ),
            ),
            Expanded(
              child: TextFormField(
                controller: controller,
                keyboardType: TextInputType.phone,
                validator: isRequired
                    ? (val) => (val == null || val.trim().isEmpty) ? 'Phone number required' : null
                    : null,
                style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                decoration: InputDecoration(
                  hintText: '74104 10123',
                  hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                    borderSide: BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                    borderSide: BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: BorderRadius.horizontal(right: Radius.circular(6)),
                    borderSide: BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTagsField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Tags'),
        TextFormField(
          controller: _tagsCtrl,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
          decoration: InputDecoration(
            hintText: 'Enter a new tag',
            hintStyle: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Provide multiple tags separated by enter',
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Status'),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          isExpanded: true,
          hint: const Text('Please select status', style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8))),
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
            ),
          ),
          items: _statusOptions.map((st) {
            return DropdownMenuItem<String>(
              value: st,
              child: Text(st, style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B))),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val),
        ),
      ],
    );
  }

  Widget _buildAssignField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Assign Lead(s) to', isRequired: true),
        InkWell(
          onTap: () => setState(() => _assignToSpecificEmployee = true),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _assignToSpecificEmployee ? const Color(0xFFF59E0B) : const Color(0xFFCBD5E1),
                      width: 2,
                    ),
                  ),
                  child: _assignToSpecificEmployee
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Specific Employee(s)',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          initialValue: _selectedEmployee,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
              borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
            ),
          ),
          items: _employeeList.map((emp) {
            return DropdownMenuItem<String>(
              value: emp,
              child: Text(
                emp,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedEmployee = val);
          },
        ),
      ],
    );
  }
}
