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
                      'Plans preview & licensing tiers (Enterprise Internal Mode)',
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
            const SizedBox(height: 16),

            // Private Internal Company Mode Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_rounded, color: Color(0xFF16A34A), size: 22),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🏢 Single-Company Internal Mode Active',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'This workspace operates under your company\'s centralized enterprise master license. Individual department billing and plan purchases are restricted to White-Label deployment. All department quotas are allocated directly by Super Admin.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF166534)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                      'Internal Master License: All department modules fully unlocked.',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        title: const Row(
                          children: [
                            Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
                            SizedBox(width: 10),
                            Text('Private Company Mode Active', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        content: const Text(
                          'Currently, Takse Call is running in Private Internal Company Mode.\n\nIndividual departments (UI/UX, Frontend, Backend, QA, Sales) do not need to purchase separate plans. SaaS billing and plan checkout will be enabled when multi-tenant White-Label mode is activated.\n\nAll department resources and limits are managed directly by your Super Admin.',
                          style: TextStyle(fontSize: 13, height: 1.4),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Understood'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_rounded, size: 16),
                  label: const Text('Managed by Super Admin (Active)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
