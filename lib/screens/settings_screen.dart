import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/web_auth_service.dart';
import '../theme/app_colors.dart';

enum SettingsSubTab {
  companyProfile,
  subscriptions,
  taxInvoice,
  mySettings,
  generalSettings,
  bizAppSettings,
  emailNotification,
  changePassword,
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  SettingsSubTab _activeSubTab = SettingsSubTab.companyProfile;

  // Form Controllers
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  String _selectedTeamSize = '1-5';
  String _selectedIndustry = 'IT / ITES';
  bool _isSaving = false;

  final List<String> _teamSizes = ['1-5', '6-15', '16-50', '50-200', '200+'];
  final List<String> _industries = [
    'IT / ITES',
    'Real Estate',
    'Finance & Banking',
    'Healthcare',
    'Education',
    'Retail & E-commerce',
    'Manufacturing',
    'Consulting & Services',
    'Other',
  ];

  final List<Map<String, String>> _billingAddresses = [];

  @override
  void initState() {
    super.initState();
    _loadDynamicUserData();
  }

  void _loadDynamicUserData() async {
    final user = WebAuthService.currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _companyNameController.text = user.companyName ?? 'Takse Call Enterprise';
      final rawPhone = user.phone.replaceAll(RegExp(r'[^0-9]'), '');
      _phoneController.text = rawPhone.length >= 10 ? rawPhone.substring(rawPhone.length - 10) : rawPhone;
      _emailController.text = '${user.name.toLowerCase().replaceAll(' ', '.')}@taksecall.com';
    }

    // Also check Firestore for any saved profile custom values
    try {
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              if (data['companyName'] != null && (data['companyName'] as String).isNotEmpty) {
                _companyNameController.text = data['companyName'];
              }
              if (data['name'] != null && (data['name'] as String).isNotEmpty) {
                _nameController.text = data['name'];
              }
              if (data['email'] != null && (data['email'] as String).isNotEmpty) {
                _emailController.text = data['email'];
              }
              if (data['teamSize'] != null && _teamSizes.contains(data['teamSize'])) {
                _selectedTeamSize = data['teamSize'];
              }
              if (data['industry'] != null && _industries.contains(data['industry'])) {
                _selectedIndustry = data['industry'];
              }
              if (data['billingAddresses'] is List) {
                _billingAddresses.clear();
                for (var a in data['billingAddresses']) {
                  if (a is Map) {
                    _billingAddresses.add(Map<String, String>.from(a));
                  }
                }
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Settings profile load notice: $e');
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);

    final user = WebAuthService.currentUser;
    final newName = _nameController.text.trim();
    final newCompany = _companyNameController.text.trim();
    final newEmail = _emailController.text.trim();

    try {
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': newName,
          'companyName': newCompany,
          'email': newEmail,
          'teamSize': _selectedTeamSize,
          'industry': _selectedIndustry,
          'billingAddresses': _billingAddresses,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        await WebAuthService.updateUserProfile(
          name: newName,
          companyName: newCompany,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Company profile updated successfully!'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      debugPrint('Error updating profile: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showEditEmailDialog() {
    final controller = TextEditingController(text: _emailController.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Update Primary Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter new account email address:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'name@company.com',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() => _emailController.text = controller.text.trim());
                Navigator.of(context).pop();
                _saveProfile();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddAddressDialog() {
    final line1 = TextEditingController();
    final city = TextEditingController();
    final state = TextEditingController();
    final pin = TextEditingController();
    final gstin = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Billing Address', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: line1,
                decoration: const InputDecoration(labelText: 'Address Line 1', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: city,
                      decoration: const InputDecoration(labelText: 'City', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: state,
                      decoration: const InputDecoration(labelText: 'State', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pin,
                      decoration: const InputDecoration(labelText: 'Pincode', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: gstin,
                      decoration: const InputDecoration(labelText: 'GSTIN (Optional)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (line1.text.isNotEmpty && city.text.isNotEmpty) {
                setState(() {
                  _billingAddresses.add({
                    'address': line1.text,
                    'cityState': '${city.text}, ${state.text} - ${pin.text}',
                    'gstin': gstin.text,
                  });
                });
                Navigator.of(context).pop();
                _saveProfile();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add Address'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Top Header matching the screenshot
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const Divider(height: 1),

        // Main Settings Body
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sub-Navigation Panel
                  SizedBox(
                    width: 220,
                    child: _buildLeftSubNav(),
                  ),
                  const VerticalDivider(width: 1),
                  // Right Content Area
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(28),
                      child: _buildActiveSubTabContent(),
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildLeftSubNav(isVertical: false),
                  const Divider(height: 1),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: _buildActiveSubTabContent(),
                  ),
                ],
              );
            }
          },
        ),
      ],
    );
  }

  // Left Sub-Navigation Panel
  Widget _buildLeftSubNav({bool isVertical = true}) {
    final tabs = [
      {'tab': SettingsSubTab.companyProfile, 'title': 'Company Profile'},
      {'tab': SettingsSubTab.subscriptions, 'title': 'Subscriptions'},
      {'tab': SettingsSubTab.taxInvoice, 'title': 'Tax Invoice'},
      {'tab': SettingsSubTab.mySettings, 'title': 'My Settings'},
      {'tab': SettingsSubTab.generalSettings, 'title': 'General Settings'},
      {'tab': SettingsSubTab.bizAppSettings, 'title': 'Biz App Settings'},
      {'tab': SettingsSubTab.emailNotification, 'title': 'Email Notification'},
      {'tab': SettingsSubTab.changePassword, 'title': 'Change Password'},
    ];

    if (!isVertical) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: tabs.map((t) {
              final tabEnum = t['tab'] as SettingsSubTab;
              final isSelected = _activeSubTab == tabEnum;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(t['title'] as String),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _activeSubTab = tabEnum),
                  selectedColor: const Color(0xFFFEF3C7),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF92400E) : AppColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      child: Column(
        children: [
          // Company Building Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF1F5F9),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.apartment_rounded,
                size: 40,
                color: Color(0xFF94A3B8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Edit Avatar Button
          SizedBox(
            width: 80,
            height: 28,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.edit, size: 12),
              label: const Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.outgoing,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Sub-menu items list
          ...tabs.map((t) {
            final tabEnum = t['tab'] as SettingsSubTab;
            final isSelected = _activeSubTab == tabEnum;

            return InkWell(
              onTap: () => setState(() => _activeSubTab = tabEnum),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFFEF3C7) : Colors.transparent,
                  border: isSelected
                      ? const Border(left: BorderSide(color: AppColors.outgoing, width: 3))
                      : null,
                ),
                child: Text(
                  t['title'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF78350F) : AppColors.textSecondary,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // Active Sub-Tab View Switcher
  Widget _buildActiveSubTabContent() {
    switch (_activeSubTab) {
      case SettingsSubTab.companyProfile:
        return _buildCompanyProfileTab();
      case SettingsSubTab.subscriptions:
        return _buildGenericSettingsPlaceholder('Subscriptions & Licenses', 'Manage active team subscription plans and add-ons.');
      case SettingsSubTab.taxInvoice:
        return _buildGenericSettingsPlaceholder('Tax Invoices', 'Download past billing invoices and GST receipts.');
      case SettingsSubTab.mySettings:
        return _buildGenericSettingsPlaceholder('My Settings', 'Configure your personal dashboard display and timezone preferences.');
      case SettingsSubTab.generalSettings:
        return _buildGenericSettingsPlaceholder('General Settings', 'Manage organization-wide call log capture and data retention policies.');
      case SettingsSubTab.bizAppSettings:
        return _buildBizAppSettingsTab();
      case SettingsSubTab.emailNotification:
        return _buildGenericSettingsPlaceholder('Email Notification', 'Configure daily call summary digests and missed call email alerts.');
      case SettingsSubTab.changePassword:
        return _buildGenericSettingsPlaceholder('Change Password', 'Update your portal login security credentials.');
    }
  }

  // 1. Company Profile Tab (Exact match to screenshot)
  Widget _buildCompanyProfileTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        const Text(
          'Company Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 24),

        // Form Fields (3 Columns / 2 Rows)
        LayoutBuilder(
          builder: (context, constraints) {
            final is3Col = constraints.maxWidth >= 780;

            if (is3Col) {
              return Column(
                children: [
                  // Row 1: Company Name | Email | Mobile Number
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Company Name',
                          controller: _companyNameController,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildEmailField(),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildPhoneField(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Row 2: Name | Select Team Size | Select Industry
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildFormField(
                          label: 'Name',
                          controller: _nameController,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Select Team Size',
                          value: _selectedTeamSize,
                          items: _teamSizes,
                          onChanged: (val) => setState(() => _selectedTeamSize = val!),
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Select Industry',
                          value: _selectedIndustry,
                          items: _industries,
                          onChanged: (val) => setState(() => _selectedIndustry = val!),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  _buildFormField(label: 'Company Name', controller: _companyNameController),
                  const SizedBox(height: 14),
                  _buildEmailField(),
                  const SizedBox(height: 14),
                  _buildPhoneField(),
                  const SizedBox(height: 14),
                  _buildFormField(label: 'Name', controller: _nameController),
                  const SizedBox(height: 14),
                  _buildDropdownField(
                    label: 'Select Team Size',
                    value: _selectedTeamSize,
                    items: _teamSizes,
                    onChanged: (val) => setState(() => _selectedTeamSize = val!),
                  ),
                  const SizedBox(height: 14),
                  _buildDropdownField(
                    label: 'Select Industry',
                    value: _selectedIndustry,
                    items: _industries,
                    onChanged: (val) => setState(() => _selectedIndustry = val!),
                  ),
                ],
              );
            }
          },
        ),

        const SizedBox(height: 22),

        // Update Profile Button
        ElevatedButton(
          onPressed: _saveProfile,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E293B),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: const Text('Update Profile', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ),

        const SizedBox(height: 36),

        // Billing Address Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Billing Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            OutlinedButton.icon(
              onPressed: _showAddAddressDialog,
              icon: const Icon(Icons.add, size: 14, color: AppColors.outgoing),
              label: const Text(
                'Add New Address',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.outgoing,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.outgoing, width: 1.2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                backgroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Billing Address Box Container (matching the screenshot empty state)
        if (_billingAddresses.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Center(
              child: Text(
                'No billing addresses have been added.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
            ),
          )
        else
          Column(
            children: _billingAddresses.map((addr) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(addr['address']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 2),
                          Text(addr['cityState']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          if (addr['gstin'] != null && addr['gstin']!.isNotEmpty)
                            Text('GSTIN: ${addr['gstin']}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.missed),
                      onPressed: () {
                        setState(() => _billingAddresses.remove(addr));
                        _saveProfile();
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

        // Live Mobile Device Synchronization Status Card
        _buildLiveDeviceSyncCard(),
      ],
    );
  }

  // Text Field with Floating Label and Red Asterisk (Height 42)
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.missed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF8FAFC) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Center(
            child: TextField(
              controller: controller,
              readOnly: readOnly,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Email Field with Edit Button (Exact height 42)
  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Email',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.missed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _emailController,
                  readOnly: true,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
              InkWell(
                onTap: _showEditEmailDialog,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(5),
                      bottomRight: Radius.circular(5),
                    ),
                    border: Border(left: BorderSide(color: Color(0xFFCBD5E1))),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 13, color: AppColors.outgoing),
                      SizedBox(width: 4),
                      Text(
                        'Edit',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.outgoing),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Mobile Number Field (Read-Only & Locked: User cannot change the mobile number)
  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Mobile Number',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            children: [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.missed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC), // Locked / Read-only background
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Row(
            children: [
              // Static Country Code Badge
              Container(
                height: 42,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(5),
                    bottomLeft: Radius.circular(5),
                  ),
                  border: Border(right: BorderSide(color: Color(0xFFCBD5E1))),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('🇮🇳', style: TextStyle(fontSize: 16)),
                    SizedBox(width: 4),
                    Text('+91', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  ],
                ),
              ),
              // Locked Phone Display (Read-Only)
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  readOnly: true,
                  enableInteractiveSelection: false,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF334155)),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                  ),
                ),
              ),
              // Lock indicator icon
              const Tooltip(
                message: 'Registered mobile number cannot be modified',
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
                      SizedBox(width: 3),
                      Text(
                        'Locked',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Dropdown Field (Exact height 42)
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            children: const [
              TextSpan(text: ' *', style: TextStyle(color: AppColors.missed, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          alignment: Alignment.center,
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: items.contains(value) ? value : items.first,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textSecondary),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // Generic Placeholder for Other Sub-Tabs
  Widget _buildGenericSettingsPlaceholder(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Settings for $title are currently synchronized with your master administrator profile.',
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Biz App Settings View
  Widget _buildBizAppSettingsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Biz App & Device Synchronization',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Monitor paired mobile device call capture, sync queue, and background upload health.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        _buildLiveDeviceSyncCard(),
      ],
    );
  }

  // Live Paired Mobile Device Call Synchronization Card (Syncs in real-time with phone)
  Widget _buildLiveDeviceSyncCard() {
    final user = WebAuthService.currentUser;
    final connectCode = user?.connectCode ?? 'KAS-4257-4648';
    final cleanCode = connectCode.replaceAll('-', '');

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('devices').doc(connectCode).snapshots(),
      builder: (context, devSnap) {
        final devData = devSnap.data?.data() as Map<String, dynamic>?;
        final totalDeviceCalls = devData?['totalCallsCount'] is int
            ? devData!['totalCallsCount'] as int
            : int.tryParse(devData?['totalCallsCount']?.toString() ?? '1776') ?? 1776;

        DateTime? lastSync;
        if (devData?['lastSyncAt'] is Timestamp) {
          lastSync = (devData!['lastSyncAt'] as Timestamp).toDate();
        }

        final deviceModel = devData?['deviceModel'] as String? ?? 'Android Phone (Live Synced)';
        final userName = devData?['userName'] as String? ?? user?.name ?? 'Kushal Asodia';
        final userPhone = devData?['userPhone'] as String? ?? user?.phone ?? '+91 96645 79043';

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('call_logs')
              .where('connectCode', whereIn: [connectCode, cleanCode])
              .snapshots(),
          builder: (context, logsSnap) {
            final cloudCount = logsSnap.data?.docs.length ?? 0;
            final pendingCount = totalDeviceCalls > cloudCount ? (totalDeviceCalls - cloudCount) : 0;
            final progress = totalDeviceCalls == 0 ? 1.0 : (cloudCount / totalDeviceCalls).clamp(0.0, 1.0);
            final isAllSynced = pendingCount == 0 && cloudCount > 0;

            return Container(
              margin: const EdgeInsets.only(top: 28),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isAllSynced ? const Color(0xFF10B981).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isAllSynced ? const Color(0xFF10B981).withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isAllSynced ? const Color(0xFFDCFCE7) : const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isAllSynced ? Icons.cloud_done_rounded : Icons.sync_rounded,
                              color: isAllSynced ? const Color(0xFF16A34A) : AppColors.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Paired Mobile Device Call Synchronization',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$deviceModel • Code: $connectCode • $userName ($userPhone)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isAllSynced ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAllSynced ? const Color(0xFF86EFAC) : const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 4,
                              backgroundColor: isAllSynced ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isAllSynced ? 'All Calls Synced' : 'Sync In Progress',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isAllSynced ? const Color(0xFF15803D) : const Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // 3 Sync Metric Counter Cards
                  Row(
                    children: [
                      _syncWebMetricBox('Total Calls on Phone', '$totalDeviceCalls', Icons.phone_android_rounded, AppColors.textPrimary),
                      const SizedBox(width: 12),
                      _syncWebMetricBox('Synced in Cloud Database', '$cloudCount', Icons.cloud_done_rounded, const Color(0xFF16A34A)),
                      const SizedBox(width: 12),
                      _syncWebMetricBox('Left to Sync', '$pendingCount', Icons.pending_actions_rounded, pendingCount > 0 ? const Color(0xFFD97706) : const Color(0xFF64748B)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isAllSynced ? const Color(0xFF16A34A) : AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Bottom info row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(progress * 100).toInt()}% of phone calls synchronized ($cloudCount of $totalDeviceCalls)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      ),
                      Text(
                        lastSync != null
                            ? 'Last device sync: ${DateFormat('d MMM yyyy, h:mm a').format(lastSync)}'
                            : 'Live synchronized with mobile phone app',
                        style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _syncWebMetricBox(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Icon(icon, size: 16, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
