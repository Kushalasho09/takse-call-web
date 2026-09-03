import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SubscriptionDialog extends StatefulWidget {
  const SubscriptionDialog({super.key});

  @override
  State<SubscriptionDialog> createState() => _SubscriptionDialogState();
}

class _SubscriptionDialogState extends State<SubscriptionDialog> {
  int _selectedPlanIndex = 1; // Pro is default

  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'Starter',
      'price': '₹499',
      'period': '/ month',
      'description': 'For individual professionals & freelancers',
      'features': [
        'Up to 2 SIM Cards tracking',
        '30-day Call History storage',
        'Basic Call Analytics & Reports',
        'Email Support',
      ],
      'isPopular': false,
    },
    {
      'name': 'Professional',
      'price': '₹1,299',
      'period': '/ month',
      'description': 'For fast-growing sales & support teams',
      'features': [
        'Unlimited SIM Devices & Sync',
        'Unlimited Cloud History backup',
        'Real-time Live Analytics & Insights',
        'CRM & Webhook Connectors',
        'Custom Lead Tagging & Auto-notes',
        'Priority 24/7 Chat & Phone Support',
      ],
      'isPopular': true,
    },
    {
      'name': 'Enterprise',
      'price': '₹3,499',
      'period': '/ month',
      'description': 'For large organizations needing custom setup',
      'features': [
        'Everything in Professional',
        'Custom Role Permissions & Multi-Org',
        'Dedicated Account Manager',
        'Custom API Integrations & Webhooks',
        '99.9% SLA & Enterprise Security',
      ],
      'isPopular': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: Colors.white,
      child: Container(
        width: 820,
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.outgoingSubtle,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.shopping_cart_outlined, color: AppColors.outgoing, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Upgrade Takse Call Subscription',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose a plan that fits your call monitoring and team management needs',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(_plans.length, (index) {
                final plan = _plans[index];
                final isSelected = _selectedPlanIndex == index;
                final isPopular = plan['isPopular'] as bool;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(
                      left: index == 0 ? 0 : 8,
                      right: index == _plans.length - 1 ? 0 : 8,
                    ),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primarySubtle.withValues(alpha: 0.5) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPopular)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'MOST POPULAR',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                          ),
                        Text(
                          plan['name'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          plan['description'],
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              plan['price'],
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              plan['period'],
                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const Divider(height: 1),
                        const SizedBox(height: 14),
                        ...((plan['features'] as List<String>).map(
                          (f) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.incoming),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    f,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textPrimary, height: 1.3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() => _selectedPlanIndex = index);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected ? AppColors.primary : Colors.white,
                              foregroundColor: isSelected ? Colors.white : AppColors.primary,
                              elevation: 0,
                              side: BorderSide(color: isSelected ? Colors.transparent : AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                            child: Text(isSelected ? 'Selected' : 'Choose Plan', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.shield_outlined, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      '30-day money-back guarantee. No questions asked.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Proceeding with ${_plans[_selectedPlanIndex]['name']} plan checkout...'),
                        backgroundColor: AppColors.primary,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_outline_rounded, size: 16),
                  label: const Text('Proceed to Payment'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
