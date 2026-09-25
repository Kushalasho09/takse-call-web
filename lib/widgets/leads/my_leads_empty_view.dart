import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class MyLeadsEmptyView extends StatelessWidget {
  final VoidCallback onAddLead;
  final VoidCallback onImportLeads;
  final VoidCallback? onSwitchToTable;

  const MyLeadsEmptyView({
    super.key,
    required this.onAddLead,
    required this.onImportLeads,
    this.onSwitchToTable,
  });

  void _showTutorialDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.play_circle_fill_rounded, color: Color(0xFFF59E0B), size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'How To Import Bulk Leads',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Follow these simple steps to import leads in bulk via CSV:',
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              _buildTutorialStep(
                step: '1',
                title: 'Download Sample CSV Template',
                desc: 'Click on "Import Leads" and download the sample CSV structure.',
              ),
              _buildTutorialStep(
                step: '2',
                title: 'Prepare Your Lead Contacts',
                desc: 'Ensure First Name and Mobile Phone numbers are filled without commas.',
              ),
              _buildTutorialStep(
                step: '3',
                title: 'Upload and Map Columns',
                desc: 'Drag & drop the file into the upload zone and verify mapped CRM fields.',
              ),
              _buildTutorialStep(
                step: '4',
                title: 'Auto-Assign and Sync',
                desc: 'Leads will immediately appear in your Assigned Leads pipeline.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              onImportLeads();
            },
            icon: const Icon(Icons.file_upload_outlined, size: 16),
            label: const Text('Start Import Now'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialStep({required String step, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: const Color(0xFFF59E0B),
            child: Text(
              step,
              style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5)),
                Text(desc, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar matching Screenshot 1
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              children: [
                const Text(
                  'My Leads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (onSwitchToTable != null) ...[
                  const Spacer(),
                  TextButton.icon(
                    onPressed: onSwitchToTable,
                    icon: const Icon(Icons.table_chart_outlined, size: 16),
                    label: const Text('View Leads Table (Preview)'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF59E0B),
                      textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // Content body
          Padding(
            padding: const EdgeInsets.all(24),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 850;
                if (isWide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildLeftInfoCard(context)),
                      const SizedBox(width: 24),
                      Expanded(flex: 5, child: _buildRightTutorialCard(context)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildLeftInfoCard(context),
                      const SizedBox(height: 24),
                      _buildRightTutorialCard(context),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeftInfoCard(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 250),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 14.5,
                color: Color(0xFF475569),
                height: 1.65,
                fontFamily: 'sans-serif',
              ),
              children: [
                TextSpan(text: 'You can add Bulk Leads in CSV Format. To add bulk leads on Callyzer, click on the '),
                TextSpan(
                  text: "'Import Leads'",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                TextSpan(text: " Button and upload the CSV Files. You can add single lead by click on the "),
                TextSpan(
                  text: "'Add lead'",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                ),
                TextSpan(text: ' Button.'),
              ],
            ),
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ElevatedButton.icon(
                onPressed: onAddLead,
                icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
                label: const Text(
                  'Add Lead',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              ElevatedButton.icon(
                onPressed: onImportLeads,
                icon: const Icon(Icons.description_outlined, size: 16),
                label: const Text(
                  'Import Leads',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRightTutorialCard(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "How To Import Bulk Leads? Click Here"
        Row(
          children: [
            const Text(
              'How To Import Bulk Leads? ',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            InkWell(
              onTap: () => _showTutorialDialog(context),
              child: const Text(
                'Click Here',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFF59E0B),
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFF59E0B),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Video Thumbnail Banner matching screenshot
        InkWell(
          onTap: () => _showTutorialDialog(context),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFFE2E8F0), Color(0xFFF8FAFC), Color(0xFFFFFFFF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [
                // Keyboard background styling elements
                Positioned(
                  left: -10,
                  top: 10,
                  bottom: 10,
                  width: 140,
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1)),
                      ),
                      child: const Center(
                        child: Icon(Icons.keyboard_outlined, size: 70, color: Color(0xFF94A3B8)),
                      ),
                    ),
                  ),
                ),

                // Yellow Enter pointer arrow
                Positioned(
                  left: 105,
                  top: 90,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.arrow_upward_rounded,
                      color: Color(0xFFF59E0B),
                      size: 48,
                    ),
                  ),
                ),

                // Main headline text
                Positioned(
                  top: 28,
                  left: 140,
                  right: 20,
                  child: Column(
                    children: const [
                      Text(
                        'How To Import Bulk Leads',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'In- CALLYZER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),

                // Play Button icon in the center
                Center(
                  child: Container(
                    width: 52,
                    height: 52,
                    margin: const EdgeInsets.only(top: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),

                // Bottom Right Callyzer Logo Emblem
                Positioned(
                  bottom: 14,
                  right: 18,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0F172A), size: 16),
                            SizedBox(width: 2),
                            Icon(Icons.bar_chart_rounded, color: Color(0xFFF59E0B), size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Callyzer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF334155),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
