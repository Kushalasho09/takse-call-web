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
                TextSpan(text: 'You can add Bulk Leads in CSV Format. To add bulk leads on Takse Call, click on the '),
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

        // Video Thumbnail Banner with Generated Takse Call Banner
        InkWell(
          onTap: () => _showTutorialDialog(context),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: const [
                BoxShadow(color: Color(0x10000000), blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  'assets/images/takse_bulk_leads_banner.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      'assets/images/takse_bulk_leads_banner.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _buildFallbackBanner(),
                    );
                  },
                ),
                // Subtle hover overlay
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showTutorialDialog(context),
                    hoverColor: Colors.black.withValues(alpha: 0.05),
                    splashColor: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackBanner() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A8A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.play_circle_fill_rounded, size: 54, color: Color(0xFFF59E0B)),
            SizedBox(height: 10),
            Text(
              'How To Import Bulk Leads in Takse Call',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
