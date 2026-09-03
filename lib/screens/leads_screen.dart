import 'package:flutter/material.dart';
import '../models/nav_item.dart';
import '../theme/app_colors.dart';
import '../widgets/sub_section_nav_bar.dart';

class LeadsScreen extends StatefulWidget {
  final String? activeSubItemId;
  final ValueChanged<String>? onSubItemSelected;

  const LeadsScreen({
    super.key,
    this.activeSubItemId,
    this.onSubItemSelected,
  });

  @override
  State<LeadsScreen> createState() => _LeadsScreenState();
}

class _LeadsScreenState extends State<LeadsScreen> {
  late String _selectedSubItem;

  @override
  void initState() {
    super.initState();
    _selectedSubItem = widget.activeSubItemId ?? 'my_leads';
  }

  @override
  void didUpdateWidget(covariant LeadsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeSubItemId != null && widget.activeSubItemId != _selectedSubItem) {
      setState(() {
        _selectedSubItem = widget.activeSubItemId!;
      });
    }
  }

  void _onSelect(String id) {
    setState(() {
      _selectedSubItem = id;
    });
    if (widget.onSubItemSelected != null) {
      widget.onSubItemSelected!(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SubSectionNavBar(
            title: 'Leads',
            description: 'Manage prospect pipelines, lead sources, conversion funnels, follow-ups, and custom tags.',
            items: NavMenuData.leadsOptions,
            selectedSubItemId: _selectedSubItem,
            onSubItemSelected: _onSelect,
            actionButtons: _buildHeaderActions(),
          ),
          const SizedBox(height: 12),
          _buildActiveView(),
        ],
      ),
    );
  }

  List<Widget> _buildHeaderActions() {
    switch (_selectedSubItem) {
      case 'my_leads':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddLeadDialog(context),
            icon: const Icon(Icons.person_add_rounded, size: 16),
            label: const Text('Add Lead'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'import_leads':
        return [
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.download_rounded, size: 16),
            label: const Text('Download Sample CSV'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'lead_tags':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddTagDialog(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Create Tag'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      case 'lead_status':
        return [
          ElevatedButton.icon(
            onPressed: () => _showAddStatusStageDialog(context),
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add Pipeline Stage'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Widget _buildActiveView() {
    switch (_selectedSubItem) {
      case 'my_leads':
        return _buildMyLeadsView();
      case 'import_leads':
        return _buildImportLeadsView();
      case 'lead_reports':
        return _buildLeadReportsView();
      case 'status_report':
        return _buildStatusReportView();
      case 'lead_not_contacted':
        return _buildLeadNotContactedView();
      case 'status_change_report':
        return _buildStatusChangeReportView();
      case 'lead_overview_report':
        return _buildLeadOverviewReportView();
      case 'lead_tags':
        return _buildLeadTagsView();
      case 'lead_status':
        return _buildLeadStatusView();
      case 'form_settings':
        return _buildFormSettingsView();
      default:
        return _buildMyLeadsView();
    }
  }

  // 1. My Leads View
  Widget _buildMyLeadsView() {
    final leads = [
      {'name': 'Rahul Sharma', 'number': '+91 98250 12345', 'company': 'Tech Corp', 'tag': 'Hot Lead', 'stage': 'Follow-Up Due', 'calls': '4 calls', 'lastCall': 'Today, 2:15 PM'},
      {'name': 'Priya Verma', 'number': '+91 97123 45678', 'company': 'Design Hub', 'tag': 'Scheduled', 'stage': 'Demo Scheduled', 'calls': '2 calls', 'lastCall': 'Yesterday, 5:30 PM'},
      {'name': 'Ananya Roy', 'number': '+91 97222 33344', 'company': 'Creatives Inc', 'tag': 'New Lead', 'stage': 'Contacted', 'calls': '1 call', 'lastCall': 'Yesterday, 11:10 AM'},
      {'name': 'Suresh Kumar', 'number': '+91 94567 89012', 'company': 'Logistics Pro', 'tag': 'Converted', 'stage': 'Closed - Won', 'calls': '7 calls', 'lastCall': '22 Aug, 4:20 PM'},
      {'name': 'Manish Tiwari', 'number': '+91 93111 22334', 'company': 'Apex Builders', 'tag': 'Hot Lead', 'stage': 'Quotation Sent', 'calls': '3 calls', 'lastCall': '21 Aug, 1:05 PM'},
    ];

    return Column(
      children: [
        // Sub-filter tabs (Due | Scheduled | All Leads)
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              _leadFilterPill('All Leads (48)', isSelected: true),
              _leadFilterPill('Due Follow-ups (5)', isSelected: false),
              _leadFilterPill('Scheduled Demos (12)', isSelected: false),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Text('Assigned Leads & Follow-up Pipeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const Spacer(),
                    SizedBox(
                      width: 240,
                      height: 36,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search leads...',
                          hintStyle: const TextStyle(fontSize: 12),
                          prefixIcon: const Icon(Icons.search_rounded, size: 16),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        columnSpacing: 20,
                        horizontalMargin: 16,
                        columns: const [
                          DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Company', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Lead Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Call History', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Last Contacted', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: leads.map((lead) {
                          final isHot = lead['tag'] == 'Hot Lead';
                          final isConverted = lead['tag'] == 'Converted';

                          return DataRow(cells: [
                            DataCell(Text(lead['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                            DataCell(Text(lead['number']!, style: const TextStyle(fontSize: 13))),
                            DataCell(Text(lead['company']!, style: const TextStyle(fontSize: 13))),
                            DataCell(Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isHot ? AppColors.missedSubtle : (isConverted ? AppColors.incomingSubtle : AppColors.primarySubtle),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                lead['stage']!,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isHot ? AppColors.missed : (isConverted ? AppColors.incoming : AppColors.primary)),
                              ),
                            )),
                            DataCell(Text(lead['calls']!, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600))),
                            DataCell(Text(lead['lastCall']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                            DataCell(Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16, color: AppColors.incoming),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  splashRadius: 16,
                                  tooltip: 'Quick Dial',
                                  onPressed: () {},
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16, color: AppColors.primary),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                                  splashRadius: 16,
                                  tooltip: 'WhatsApp',
                                  onPressed: () {},
                                ),
                              ],
                            )),
                          ]);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leadFilterPill(String title, {required bool isSelected}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected ? const [BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  // 2. Import Leads View
  Widget _buildImportLeadsView() {
    return Column(
      children: [
        // Drag and Drop Upload Area
        Container(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid, width: 1.5),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: const Icon(Icons.cloud_upload_outlined, size: 34, color: AppColors.primary),
              ),
              const SizedBox(height: 16),
              const Text('Drag & Drop CSV / Excel File Here', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text('Supported formats: .CSV, .XLSX, .XLS (Up to 50,000 leads per upload batch)', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.file_upload_outlined, size: 16),
                label: const Text('Browse Files'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Column Mapping Preview
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Automatic Column Header Mapping', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 4),
              const Text('Match your CSV headers with Takse Call CRM lead attributes:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 14),
              _mappingRow('Lead Full Name', 'Column A (Full Name)', true),
              _mappingRow('Primary Phone Number', 'Column B (Mobile / Phone)', true),
              _mappingRow('Company Name', 'Column C (Organization)', true),
              _mappingRow('Lead Source / Campaign', 'Column D (UTM Source)', true),
              _mappingRow('Custom Notes / Requirements', 'Column E (Notes)', true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mappingRow(String field, String mappedTo, bool isMatched) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 200, child: Text(field, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
          const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.border)),
            child: Text(mappedTo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.incoming),
        ],
      ),
    );
  }

  // 3. Lead Reports View
  Widget _buildLeadReportsView() {
    return Column(
      children: [
        Row(
          children: [
            _leadMetricCard('Total Inflow', '240 Leads', '+18% vs last month', Icons.trending_up_rounded, AppColors.primary),
            const SizedBox(width: 14),
            _leadMetricCard('Contacted Rate', '88.5%', '212 / 240 dialed', Icons.phone_callback_rounded, AppColors.incoming),
            const SizedBox(width: 14),
            _leadMetricCard('Conversion Rate', '22.5%', '54 deals closed', Icons.star_rounded, const Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Lead Source Acquisition Breakdown', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              _sourceBar('Website Inbound Forms', 0.42, '101 leads (42%)', AppColors.primary),
              const SizedBox(height: 12),
              _sourceBar('WhatsApp Direct Chat', 0.28, '67 leads (28%)', const Color(0xFF10B981)),
              const SizedBox(height: 12),
              _sourceBar('Google Ads Campaign', 0.18, '43 leads (18%)', const Color(0xFFF59E0B)),
              const SizedBox(height: 12),
              _sourceBar('Referral & Partners', 0.12, '29 leads (12%)', const Color(0xFF8B5CF6)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _leadMetricCard(String title, String value, String sub, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 4),
            Text(sub, style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _sourceBar(String name, double fraction, String stats, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            Text(stats, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 10,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // 4. Status Report View
  Widget _buildStatusReportView() {
    final stages = [
      {'stage': '1. New / Uncontacted', 'count': '45', 'pct': '18.7%', 'color': const Color(0xFF3B82F6)},
      {'stage': '2. First Contact Made', 'count': '68', 'pct': '28.3%', 'color': const Color(0xFF6366F1)},
      {'stage': '3. Follow-up In Progress', 'count': '52', 'pct': '21.6%', 'color': const Color(0xFFF59E0B)},
      {'stage': '4. Quotation / Demo Sent', 'count': '34', 'pct': '14.1%', 'color': const Color(0xFF8B5CF6)},
      {'stage': '5. Closed - Won', 'count': '28', 'pct': '11.6%', 'color': const Color(0xFF10B981)},
      {'stage': '6. Closed - Lost / Dropped', 'count': '13', 'pct': '5.4%', 'color': const Color(0xFFEF4444)},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Lead Status Funnel & Stage Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 6),
          const Text('Real-time overview of prospect status across all sales stages:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          ...stages.map((s) {
            final col = s['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  SizedBox(width: 220, child: Text(s['stage'] as String, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5))),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: double.parse((s['pct'] as String).replaceAll('%', '')) / 100,
                        minHeight: 12,
                        backgroundColor: const Color(0xFFF1F5F9),
                        valueColor: AlwaysStoppedAnimation<Color>(col),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 100,
                    child: Text('${s['count']} (${s['pct']})', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: col)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // 5. Lead Not Contacted View
  Widget _buildLeadNotContactedView() {
    final pendingLeads = [
      {'name': 'Vikash Agrawal', 'phone': '+91 98111 44556', 'source': 'Website Form', 'received': '12 mins ago', 'urgency': 'CRITICAL'},
      {'name': 'Sunil Joshi', 'phone': '+91 97222 11990', 'source': 'WhatsApp Inbound', 'received': '34 mins ago', 'urgency': 'HIGH'},
      {'name': 'Kavita Menon', 'phone': '+91 94000 88221', 'source': 'Google Ads Lead', 'received': '1 hour ago', 'urgency': 'MEDIUM'},
      {'name': 'Tarun Kapoor', 'phone': '+91 98333 77112', 'source': 'Referral Link', 'received': '2 hours ago', 'urgency': 'MEDIUM'},
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFFCD34D)),
          ),
          child: const Row(
            children: [
              Icon(Icons.timer_outlined, color: Color(0xFFD97706), size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text('Leads contacted within 15 minutes have a 7x higher conversion rate! Dial pending leads now.', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Urgency', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Prospect Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Phone Number', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Source Channel', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Waiting Time', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Instant Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: pendingLeads.map((p) {
                      final isCrit = p['urgency'] == 'CRITICAL';
                      return DataRow(cells: [
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: isCrit ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                          child: Text(p['urgency']!, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isCrit ? const Color(0xFFDC2626) : const Color(0xFFD97706))),
                        )),
                        DataCell(Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(p['phone']!, style: const TextStyle(fontSize: 13))),
                        DataCell(Text(p['source']!, style: const TextStyle(fontSize: 12))),
                        DataCell(Text(p['received']!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.missed))),
                        DataCell(ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 14),
                          label: const Text('Dial Now'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.incoming,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // 6. Status Change Report View
  Widget _buildStatusChangeReportView() {
    final changes = [
      {'lead': 'Rahul Sharma', 'from': 'Contacted', 'to': 'Demo Scheduled', 'by': 'Kushal Asodia', 'time': 'Today, 2:30 PM'},
      {'lead': 'Priya Verma', 'from': 'Demo Scheduled', 'to': 'Quotation Sent', 'by': 'Rahul Sharma', 'time': 'Today, 1:15 PM'},
      {'lead': 'Suresh Kumar', 'from': 'Negotiation', 'to': 'Closed - Won', 'by': 'Kushal Asodia', 'time': 'Yesterday, 4:20 PM'},
      {'lead': 'Amit Patel', 'from': 'New Lead', 'to': 'Contacted', 'by': 'Sneha Nair', 'time': 'Yesterday, 11:00 AM'},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Lead Stage Progression Audit Trail', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Lead Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Previous Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('New Stage', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Changed By User', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Timestamp', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: changes.map((c) {
                      return DataRow(cells: [
                        DataCell(Text(c['lead']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(c['from']!, style: const TextStyle(fontSize: 12, color: AppColors.textMuted))),
                        DataCell(Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.primarySubtle, borderRadius: BorderRadius.circular(6)),
                          child: Text(c['to']!, style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        )),
                        DataCell(Text(c['by']!, style: const TextStyle(fontSize: 12.5))),
                        DataCell(Text(c['time']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 7. Lead Overview Report View
  Widget _buildLeadOverviewReportView() {
    return Column(
      children: [
        Row(
          children: [
            _leadMetricCard('Active Pipeline Value', '₹ 14.8 Lakhs', '42 qualified deals', Icons.currency_rupee_rounded, AppColors.primary),
            const SizedBox(width: 14),
            _leadMetricCard('Avg Response Time', '4.2 Mins', 'Best in class response', Icons.speed_rounded, AppColors.incoming),
            const SizedBox(width: 14),
            _leadMetricCard('Total Inquiries', '512 Leads', 'This Quarter', Icons.contacts_outlined, const Color(0xFF8B5CF6)),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Weekly Lead Inflow Volume Trend', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              Container(
                height: 160,
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _barChartColumn('W1 Aug', 0.5, '54 leads'),
                    _barChartColumn('W2 Aug', 0.7, '78 leads'),
                    _barChartColumn('W3 Aug', 0.85, '94 leads'),
                    _barChartColumn('W4 Aug (Current)', 0.95, '108 leads'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _barChartColumn(String label, double fraction, String count) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(count, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 4),
        Container(
          width: 48,
          height: 100 * fraction,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
        const SizedBox(height: 4),
      ],
    );
  }

  // 8. Lead Tags View
  Widget _buildLeadTagsView() {
    final tags = [
      {'name': 'Hot Lead', 'color': 0xFFDC2626, 'count': '18 leads'},
      {'name': 'High Budget (₹1L+)', 'color': 0xFF16A34A, 'count': '12 leads'},
      {'name': 'Enterprise Bundle', 'color': 0xFF2563EB, 'count': '8 leads'},
      {'name': 'Demo Scheduled', 'color': 0xFF9333EA, 'count': '14 leads'},
      {'name': 'Price Sensitive', 'color': 0xFFD97706, 'count': '22 leads'},
      {'name': 'Immediate Callback', 'color': 0xFFEA580C, 'count': '6 leads'},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        mainAxisExtent: 110,
      ),
      itemCount: tags.length,
      itemBuilder: (context, index) {
        final t = tags[index];
        final col = Color(t['color'] as int);
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: col, shape: BoxShape.circle),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(t['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                    const SizedBox(height: 4),
                    Text(t['count'] as String, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                splashRadius: 14,
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  // 9. Lead Status View
  Widget _buildLeadStatusView() {
    final stages = [
      {'order': '1', 'name': 'New Inflow', 'rule': 'Assigned automatically via round-robin'},
      {'order': '2', 'name': 'Contacted', 'rule': 'Triggered after 1st call log recorded'},
      {'order': '3', 'name': 'Follow-Up Scheduled', 'rule': 'Requires next follow-up date'},
      {'order': '4', 'name': 'Proposal / Quotation', 'rule': 'Sent quotation link to lead'},
      {'order': '5', 'name': 'Closed - Won', 'rule': 'Payment confirmed in gateway'},
      {'order': '6', 'name': 'Closed - Lost', 'rule': 'Requires lost reason note'},
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Configured Sales Pipeline Stages', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const Divider(height: 1),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                    columnSpacing: 20,
                    horizontalMargin: 16,
                    columns: const [
                      DataColumn(label: Text('Stage Order', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Stage Name', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Automation Rule', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: stages.map((s) {
                      return DataRow(cells: [
                        DataCell(CircleAvatar(radius: 12, backgroundColor: AppColors.primarySubtle, child: Text(s['order']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)))),
                        DataCell(Text(s['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                        DataCell(Text(s['rule']!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                        DataCell(IconButton(
                          icon: const Icon(Icons.settings_outlined, size: 16, color: AppColors.textMuted),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                          splashRadius: 16,
                          onPressed: () {},
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // 10. Form Settings View
  Widget _buildFormSettingsView() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Website Lead Capture Form & Webhook Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          const Text('Incoming Leads Webhook URL (POST):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
            child: Row(
              children: [
                const Expanded(child: Text('https://api.taksecall.com/v1/webhook/leads/wh_live_88301923', style: TextStyle(fontSize: 12.5, fontFamily: 'monospace'))),
                IconButton(icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.primary), tooltip: 'Copy Webhook URL', onPressed: () {}),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Embed HTML Widget Form Snippet:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
            child: const Text(
              '<script src="https://cdn.taksecall.com/lead-widget.js" data-company-id="KUS-3926-0820" async></script>',
              style: TextStyle(fontSize: 12, color: Color(0xFF38BDF8), fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddLeadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add New Lead'),
        content: SizedBox(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Lead Full Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Company / Organization', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Initial Lead Tag (e.g. Hot Lead)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead added to pipeline.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save Lead'),
          ),
        ],
      ),
    );
  }

  void _showAddTagDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Create New Lead Tag'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Tag Label', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lead tag created.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Create Tag'),
          ),
        ],
      ),
    );
  }

  void _showAddStatusStageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Pipeline Stage'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Stage Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
              const SizedBox(height: 12),
              TextField(decoration: InputDecoration(labelText: 'Trigger / Requirement Rule', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pipeline stage added.')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Save Stage'),
          ),
        ],
      ),
    );
  }
}
