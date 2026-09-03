import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScheduleDemoDialog extends StatefulWidget {
  const ScheduleDemoDialog({super.key});

  @override
  State<ScheduleDemoDialog> createState() => _ScheduleDemoDialogState();
}

class _ScheduleDemoDialogState extends State<ScheduleDemoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Kushal Asodia');
  final _emailController = TextEditingController(text: 'kushal@example.com');
  final _phoneController = TextEditingController(text: '+91 99782 17711');
  String _selectedTimeSlot = 'Today, 4:00 PM - 4:30 PM';
  bool _isSubmitted = false;

  final List<String> _slots = [
    'Today, 4:00 PM - 4:30 PM',
    'Today, 6:00 PM - 6:30 PM',
    'Tomorrow, 11:00 AM - 11:30 AM',
    'Tomorrow, 3:00 PM - 3:30 PM',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(24),
        child: _isSubmitted ? _buildSuccessView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primarySubtle,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.headset_mic_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Schedule a Live Demo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Get a guided walkthrough of Takse Call Web',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                splashRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Your Name', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _nameController,
            decoration: _inputDecoration('Enter your full name', Icons.person_outline_rounded),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          const Text('Work Email', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _emailController,
            decoration: _inputDecoration('Enter your work email', Icons.mail_outline_rounded),
            validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 14),
          const Text('Phone Number', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: _phoneController,
            decoration: _inputDecoration('Enter phone number', Icons.phone_outlined),
          ),
          const SizedBox(height: 14),
          const Text('Preferred Time Slot', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _selectedTimeSlot,
            items: _slots.map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 13)))).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _selectedTimeSlot = val);
            },
            decoration: _inputDecoration('', Icons.calendar_today_outlined),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    setState(() => _isSubmitted = true);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Confirm Booking'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded, color: AppColors.incoming, size: 54),
        const SizedBox(height: 16),
        const Text(
          'Demo Scheduled Successfully!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'We have reserved your slot for $_selectedTimeSlot. A meeting invite has been sent to ${_emailController.text}.',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Got it'),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }
}
