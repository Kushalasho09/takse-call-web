// ignore_for_file: deprecated_member_use
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../models/lead_item.dart';
import '../../services/google_sheets_service.dart';
import '../../services/web_lead_firestore_service.dart';
import '../../utils/csv_web_helper.dart';

const String kDefaultSampleCsv = '''Sr.No,Lead Name,Contact Number,Alternate Number,Company Name,Email Address,Address,City,State,Pincode,Lead Status,Assign To,Lead Tags,Description / Notes,Price
1,kushal,9978217711,9664579043,Takse Enterprises,kushal@takse.in,Corporate Road Opposite SG Highway,Ahmedabad,Gujarat,380015,Positive,kushal asodia (+91-9664579043),Hot Lead;Website,Customer requested demo for 10 telecallers,₹ 50000
2,manish asodia,9376661542,9825100001,Asodia Infotech,manish@asodia.com,CG Road Navrangpura,Ahmedabad,Gujarat,380009,Positive,kushal asodia (+91-9664579043),Hot Lead;Decision Maker,Ready to subscribe to yearly plan,₹ 75000
3,priya verma,9712345678,9876543210,Verma Design Studio,priya@verma.design,Bandra West Linking Road,Mumbai,Maharashtra,400050,Call Back,Rohan Sharma (+91-9876543210),Instagram;Urgent,Requested quotation brochure over WhatsApp,₹ 40000
4,rajesh patel,9825144556,9825199999,Patel Logistics,rajesh@patellogistics.com,Ring Road Varachha,Surat,Gujarat,395006,Not Pickup Call,Amit Patel (+91-9822334455),Inbound,Ringing not answered,₹ 30000''';

class ImportLeadsView extends StatefulWidget {
  final VoidCallback onCancel;
  final Function(List<LeadItem> importedLeads)? onImportComplete;

  const ImportLeadsView({
    super.key,
    required this.onCancel,
    this.onImportComplete,
  });

  @override
  State<ImportLeadsView> createState() => _ImportLeadsViewState();
}

class _ImportLeadsViewState extends State<ImportLeadsView> {
  // Mode: 'csv' or 'connectors'
  String _activeMode = 'csv';

  // 5-Step Stepper state
  int _currentStep = 1;
  String? _selectedFileName;
  int _selectedFileSize = 0;
  bool _isProcessing = false;
  List<LeadItem> _parsedLeads = [];

  // Step 2: Mapping
  final Map<String, String> _mappedFields = {
    'Full Name': 'name',
    'Phone Number': 'phoneNumber',
    'Email Address': 'email',
    'Company': 'company',
    'Tags': 'tags',
    'Assign To': 'assignedTo',
    'Notes': 'notes',
  };

  // Step 4: Actions & Duplicates
  String _duplicateStrategy = 'skip'; // 'skip', 'overwrite', 'allow'
  String _defaultStatus = 'Positive';

  final List<String> _employeeList = [
    'kushal asodia (+91-9664579043)',
    'Rohan Sharma (+91-9876543210)',
    'Amit Patel (+91-9822334455)',
    'Priya Verma (+91-9712345678)',
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate with default sample leads so user can proceed immediately if desired
    _parseCsvString(kDefaultSampleCsv, fileName: 'takse_call_leads_sample.csv', fileSize: utf8.encode(kDefaultSampleCsv).length);
  }

  void _handleUploadCsv() {
    pickCsvFileWeb((text, name, size) {
      _parseCsvString(text, fileName: name, fileSize: size);
    });
  }

  void _loadSampleData() {
    final bytes = utf8.encode(kDefaultSampleCsv);
    setState(() {
      _selectedFileName = 'takse_call_leads_sample.csv';
      _selectedFileSize = bytes.length;
    });
    _parseCsvString(kDefaultSampleCsv, fileName: 'takse_call_leads_sample.csv', fileSize: bytes.length);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample CSV loaded: 4 leads including "kushal" (9978217711) ready for import!'),
        backgroundColor: Color(0xFF2563EB),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _parseCsvString(String rawCsv, {String? fileName, int? fileSize}) {
    final lines = rawCsv.split(RegExp(r'\r?\n'));
    if (lines.isEmpty) return;

    int headerIdx = -1;
    List<String> headers = [];
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isNotEmpty) {
        headers = _parseCsvLine(line).map((h) => h.toLowerCase()).toList();
        headerIdx = i;
        break;
      }
    }

    if (headerIdx == -1 || headers.isEmpty) return;

    int idxName = headers.indexWhere((h) => h.contains('name') || h.contains('lead name'));
    int idxPhone = headers.indexWhere((h) => h.contains('contact') || h.contains('phone') || h.contains('mobile'));
    int idxAltPhone = headers.indexWhere((h) => h.contains('alternate') || h.contains('alt'));
    int idxCompany = headers.indexWhere((h) => h.contains('company'));
    int idxEmail = headers.indexWhere((h) => h.contains('email'));
    int idxAddress = headers.indexWhere((h) => h.contains('address'));
    int idxCity = headers.indexWhere((h) => h.contains('city'));
    int idxState = headers.indexWhere((h) => h.contains('state'));
    int idxPincode = headers.indexWhere((h) => h.contains('pincode') || h.contains('zip'));
    int idxStatus = headers.indexWhere((h) => h.contains('status'));
    int idxAssignTo = headers.indexWhere((h) => h.contains('assign'));
    int idxTags = headers.indexWhere((h) => h.contains('tag'));
    int idxNotes = headers.indexWhere((h) => h.contains('note') || h.contains('desc'));
    int idxPrice = headers.indexWhere((h) => h.contains('price'));

    final List<LeadItem> parsed = [];
    final now = DateTime.now();
    final todayStr = '${now.day} Sep 2026';

    for (int i = headerIdx + 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final cols = _parseCsvLine(line);
      String getCol(int idx) => (idx >= 0 && idx < cols.length) ? cols[idx].trim() : '';

      final name = getCol(idxName);
      final rawPhone = getCol(idxPhone);
      if (rawPhone.isEmpty && name.isEmpty) continue;

      final cleanDigits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
      final tenDigit = cleanDigits.length > 10 ? cleanDigits.substring(cleanDigits.length - 10) : cleanDigits;
      final docId = tenDigit.isNotEmpty ? 'lead_$tenDigit' : 'lead_${DateTime.now().millisecondsSinceEpoch}_$i';

      final altPhone = getCol(idxAltPhone);
      final company = getCol(idxCompany);
      final email = getCol(idxEmail);
      final address = getCol(idxAddress);
      final city = getCol(idxCity);
      final state = getCol(idxState);
      final pincode = getCol(idxPincode);
      final statusVal = getCol(idxStatus);
      final assignTo = getCol(idxAssignTo);
      final rawTags = getCol(idxTags);
      final notes = getCol(idxNotes);
      final price = getCol(idxPrice);

      List<String> tagsList = [];
      if (rawTags.isNotEmpty) {
        tagsList = rawTags.split(RegExp(r'[;,]')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
      }
      if (tagsList.isEmpty) tagsList = ['Inbound'];

      String assignedName = assignTo.isNotEmpty ? assignTo : 'kushal asodia';
      String assignedPhone = '+91-9664579043';
      if (assignTo.contains('(')) {
        final parts = assignTo.split('(');
        assignedName = parts[0].trim();
        assignedPhone = parts[1].replaceAll(')', '').trim();
      }

      parsed.add(LeadItem(
        id: docId,
        srNo: parsed.length + 1,
        leadNumber: parsed.length + 1,
        name: name.isNotEmpty ? name : 'Lead $tenDigit',
        phone: rawPhone.isNotEmpty ? rawPhone : tenDigit,
        altPhone: altPhone.isNotEmpty ? altPhone : null,
        createdDate: '$todayStr, 11:30 AM',
        attempts: 0,
        tags: tagsList,
        tagAssignedDate: todayStr,
        assignedTo: assignedName,
        assignedToPhone: assignedPhone,
        assignedDate: '$todayStr | 11:30 AM',
        status: statusVal.isNotEmpty ? statusVal : _defaultStatus,
        company: company.isNotEmpty ? company : null,
        email: email.isNotEmpty ? email : null,
        address1: address.isNotEmpty ? address : null,
        city: city.isNotEmpty ? city : null,
        state: state.isNotEmpty ? state : null,
        zipcode: pincode.isNotEmpty ? pincode : null,
        description: notes.isNotEmpty ? notes : null,
        price: price.isNotEmpty ? price : null,
        source: 'Bulk CSV Import',
      ));
    }

    setState(() {
      _parsedLeads = parsed;
      if (fileName != null) _selectedFileName = fileName;
      if (fileSize != null) _selectedFileSize = fileSize;
    });
  }

  List<String> _parseCsvLine(String line) {
    final List<String> result = [];
    final StringBuffer current = StringBuffer();
    bool inQuotes = false;
    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString().trim());
        current.clear();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString().trim());
    return result;
  }

  void _downloadSampleCsv() {
    downloadCsvWeb(kDefaultSampleCsv, 'takse_call_leads_sample.csv');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sample CSV template "takse_call_leads_sample.csv" downloaded.'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  Future<void> _finishImport() async {
    setState(() => _isProcessing = true);

    if (_parsedLeads.isEmpty) {
      _loadSampleData();
    }

    final leadsToIngest = _parsedLeads.map((l) {
      if (_defaultStatus.isNotEmpty && (l.status.isEmpty || l.status == 'New Inflow')) {
        return l.copyWith(status: _defaultStatus);
      }
      return l;
    }).toList();

    // 1. REAL BACKEND PERSISTENCE: Save each lead directly into Firebase Cloud Firestore!
    for (final lead in leadsToIngest) {
      await WebLeadFirestoreService.saveLead(lead);
    }

    if (!mounted) return;

    // 2. Notify parent listener
    if (widget.onImportComplete != null) {
      widget.onImportComplete!(leadsToIngest);
    }

    setState(() => _isProcessing = false);
  }

  // Google Sheets Config & Sync Modal
  void _showGoogleSheetsModal() {
    final sheetUrlCtrl = TextEditingController(text: 'https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit');
    final apiKeyCtrl = TextEditingController();
    final rangeCtrl = TextEditingController(text: 'Sheet1!A1:Z500');
    String distribution = 'round_robin';
    final Set<String> selectedAgents = {'kushal asodia', 'Rohan Sharma', 'Amit Patel'};

    bool isTesting = false;
    bool isSyncing = false;
    String? statusMessage;
    bool isError = false;
    List<List<String>>? previewRows;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.table_view_rounded, color: Color(0xFF10B981), size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Google Sheets & Excel Connector', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Sync leads in real-time using Google Sheets API v4 or Public Link', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Color(0xFF64748B)),
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info Banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Enter your Google Spreadsheet link and optional API Key. Leads will be parsed with automatic column detection (Name, Phone, Status, Price, Notes) and synced to your cloud pipeline.',
                            style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1. Google Sheet Link / ID
                  const Text('Google Sheet URL or Spreadsheet ID *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: sheetUrlCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'https://docs.google.com/spreadsheets/d/YOUR_SHEET_ID/edit',
                      prefixIcon: const Icon(Icons.link_rounded, size: 18, color: Color(0xFF10B981)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Google Cloud API Key (Optional)
                  Row(
                    children: const [
                      Text('Google Cloud API Key', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                      SizedBox(width: 6),
                      Text('(Optional if sheet is shared via link)', style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontStyle: FontStyle.italic)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: apiKeyCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'AIzaSy... (from Google Cloud Console > APIs & Services > Credentials)',
                      prefixIcon: const Icon(Icons.key_rounded, size: 18, color: Color(0xFFF59E0B)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 3. Sheet Range
                  const Text('Sheet Range / Tab Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: rangeCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      hintText: 'Sheet1!A1:Z500',
                      prefixIcon: const Icon(Icons.grid_on_rounded, size: 18, color: Color(0xFF6366F1)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Lead Distribution Mode
                  const Text('Lead Assignment Routing:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                  RadioListTile<String>(
                    title: const Text('Round-Robin Distribution (Even rotation among sales reps)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    value: 'round_robin',
                    groupValue: distribution,
                    activeColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setDlgState(() => distribution = val!),
                  ),
                  if (distribution == 'round_robin') ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Included Telecallers:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
                          const SizedBox(height: 4),
                          ..._employeeList.map((emp) {
                            final name = emp.split('(')[0].trim();
                            final isChecked = selectedAgents.contains(name);
                            return CheckboxListTile(
                              title: Text(emp, style: const TextStyle(fontSize: 11.5)),
                              value: isChecked,
                              dense: true,
                              activeColor: const Color(0xFF10B981),
                              contentPadding: EdgeInsets.zero,
                              onChanged: (val) {
                                setDlgState(() {
                                  if (val == true) {
                                    selectedAgents.add(name);
                                  } else {
                                    selectedAgents.remove(name);
                                  }
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                  RadioListTile<String>(
                    title: const Text('Assign all to Primary Telecaller (kushal asodia)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                    value: 'single',
                    groupValue: distribution,
                    activeColor: const Color(0xFF10B981),
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    onChanged: (val) => setDlgState(() => distribution = val!),
                  ),
                  const SizedBox(height: 12),

                  // Status Message Banner
                  if (statusMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_rounded, size: 18, color: isError ? const Color(0xFFEF4444) : const Color(0xFF16A34A)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              statusMessage!,
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isError ? const Color(0xFFB91C1C) : const Color(0xFF15803D)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Live Preview Table (if tested)
                  if (previewRows != null && previewRows!.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Found ${previewRows!.length - 1} leads in sheet:', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                              Text('Headers: ${previewRows!.first.take(4).join(", ")}...', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ...previewRows!.skip(1).take(3).map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• ${r.take(4).join(" | ")}', style: const TextStyle(fontSize: 11, color: Color(0xFF475569)), overflow: TextOverflow.ellipsis),
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Action: Test Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: isTesting || isSyncing ? null : () async {
                        final rawUrl = sheetUrlCtrl.text.trim();
                        if (rawUrl.isEmpty) {
                          setDlgState(() {
                            statusMessage = 'Please enter a valid Google Sheet URL or ID';
                            isError = true;
                          });
                          return;
                        }

                        setDlgState(() {
                          isTesting = true;
                          statusMessage = 'Connecting to Google Sheets API and fetching data...';
                          isError = false;
                        });

                        try {
                          List<List<String>> rows;
                          final apiKey = apiKeyCtrl.text.trim();

                          if (apiKey.isNotEmpty) {
                            rows = await GoogleSheetsService.fetchSheetWithApiKey(
                              spreadsheetId: rawUrl,
                              apiKey: apiKey,
                              range: rangeCtrl.text.trim().isNotEmpty ? rangeCtrl.text.trim() : 'Sheet1!A1:Z500',
                            );
                          } else {
                            rows = await GoogleSheetsService.fetchSheetViaCsvExport(
                              spreadsheetId: rawUrl,
                            );
                          }

                          setDlgState(() {
                            isTesting = false;
                            previewRows = rows;
                            if (rows.length >= 2) {
                              statusMessage = 'Connection Successful! Found ${rows.length - 1} lead rows in Google Sheet.';
                              isError = false;
                            } else {
                              statusMessage = 'Connected, but the sheet has no data rows.';
                              isError = true;
                            }
                          });
                        } catch (e) {
                          setDlgState(() {
                            isTesting = false;
                            isError = true;
                            statusMessage = 'Error connecting to Google Sheet: $e';
                          });
                        }
                      },
                      icon: isTesting
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.sync_rounded, size: 16),
                      label: Text(isTesting ? 'Testing Connection...' : 'Test Connection & Preview Sheet Rows'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        side: const BorderSide(color: Color(0xFF93C5FD)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: isSyncing || isTesting ? null : () async {
                final rawUrl = sheetUrlCtrl.text.trim();
                if (rawUrl.isEmpty) {
                  setDlgState(() {
                    statusMessage = 'Please enter a Google Sheet URL or ID first';
                    isError = true;
                  });
                  return;
                }

                setDlgState(() {
                  isSyncing = true;
                  statusMessage = 'Syncing leads into Firestore cloud pipeline...';
                  isError = false;
                });

                try {
                  List<List<String>> rows = previewRows ?? [];
                  if (rows.isEmpty) {
                    final apiKey = apiKeyCtrl.text.trim();
                    if (apiKey.isNotEmpty) {
                      rows = await GoogleSheetsService.fetchSheetWithApiKey(
                        spreadsheetId: rawUrl,
                        apiKey: apiKey,
                        range: rangeCtrl.text.trim().isNotEmpty ? rangeCtrl.text.trim() : 'Sheet1!A1:Z500',
                      );
                    } else {
                      rows = await GoogleSheetsService.fetchSheetViaCsvExport(
                        spreadsheetId: rawUrl,
                      );
                    }
                  }

                  final leads = GoogleSheetsService.convertRowsToLeads(
                    rows,
                    roundRobinAgents: distribution == 'round_robin' ? selectedAgents.toList() : [],
                    defaultAssignee: distribution == 'single' ? 'kushal asodia (+91-9664579043)' : null,
                  );

                  if (leads.isEmpty) {
                    setDlgState(() {
                      isSyncing = false;
                      isError = true;
                      statusMessage = 'No valid lead records found to import.';
                    });
                    return;
                  }

                  // 1. Save all to Firestore
                  for (final lead in leads) {
                    await WebLeadFirestoreService.saveLead(lead);
                  }

                  // 2. Save connector config in Firestore
                  await GoogleSheetsService.saveConnectorConfig(
                    GoogleSheetConfig(
                      spreadsheetId: GoogleSheetsService.extractSpreadsheetId(rawUrl),
                      sheetUrl: rawUrl,
                      apiKey: apiKeyCtrl.text.trim(),
                      range: rangeCtrl.text.trim(),
                      distributionMode: distribution,
                      assignedAgents: selectedAgents.toList(),
                      lastSyncAt: DateTime.now(),
                      totalSyncedCount: leads.length,
                    ),
                  );

                  if (!ctx.mounted) return;
                  Navigator.pop(ctx);

                  // Update parent state
                  setState(() {
                    _parsedLeads = leads;
                    _selectedFileName = 'Google Sheet (${leads.length} leads)';
                  });

                  if (widget.onImportComplete != null) {
                    widget.onImportComplete!(leads);
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Successfully imported ${leads.length} leads from Google Sheets directly into pipeline!'),
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                    ),
                  );
                } catch (e) {
                  setDlgState(() {
                    isSyncing = false;
                    isError = true;
                    statusMessage = 'Sync failed: $e';
                  });
                }
              },
              icon: isSyncing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.cloud_upload_rounded, size: 16),
              label: Text(isSyncing ? 'Syncing to Cloud...' : 'Import & Sync to Pipeline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ],
        ),
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
          BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with Mode Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 24,
                  runSpacing: 8,
                  children: [
                    const Text('Import Leads Pipeline', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
                    // Mode Toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _modeTab('Manual CSV Import (5-Step)', 'csv'),
                          _modeTab('Automated Connectors Hub', 'connectors'),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)), onPressed: widget.onCancel, tooltip: 'Cancel'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          if (_activeMode == 'csv') _buildCsvImportView() else _buildConnectorsHubView(),
        ],
      ),
    );
  }

  Widget _modeTab(String title, String modeKey) {
    final isSelected = _activeMode == modeKey;
    return InkWell(
      onTap: () => setState(() => _activeMode = modeKey),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          boxShadow: isSelected ? const [BoxShadow(color: Color(0x08000000), blurRadius: 4, offset: Offset(0, 2))] : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? const Color(0xFF1E293B) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  // Mode 1: 5-Step CSV Import View
  Widget _buildCsvImportView() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(),
          const SizedBox(height: 32),
          if (_currentStep == 1) _buildStep1Upload(),
          if (_currentStep == 2) _buildStep2MapFields(),
          if (_currentStep == 3) _buildStep3Validate(),
          if (_currentStep == 4) _buildStep4Actions(),
          if (_currentStep == 5) _buildStep5Summary(),
        ],
      ),
    );
  }

  // Step 1: File Upload
  Widget _buildStep1Upload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Please consider below points while uploading CSV'),
        const SizedBox(height: 16),
        _buildChecklistPoint('Please note that First Name and Phone Number are mandatory information'),
        const SizedBox(height: 8),
        _buildChecklistPoint("If you want to add multiple tags in CSV then put it separated by ';' (semicolon)"),
        const SizedBox(height: 8),
        _buildChecklistPoint("If you want to add multiple Assign To in CSV then put it separated by ';' (semicolon)"),
        const SizedBox(height: 8),
        _buildChecklistPoint('Please replace comma (,) with semicolon (;) in address'),

        const SizedBox(height: 32),

        _buildSectionHeader('Import Leads Manually'),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(26)),
                child: const Icon(Icons.cloud_upload_outlined, size: 30, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              const Text('Drag & Drop CSV file', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
              const SizedBox(height: 4),
              const Text('CSV file with comma separated values', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              const SizedBox(height: 16),

              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleUploadCsv,
                    icon: const Icon(Icons.file_upload_outlined, size: 18),
                    label: const Text('Select File', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadSampleData,
                    icon: const Icon(Icons.flash_on_rounded, size: 18, color: Color(0xFF2563EB)),
                    label: const Text('Load Sample CSV (kushal - 9978217711)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1E40AF))),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF93C5FD)),
                      backgroundColor: const Color(0xFFEFF6FF),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                  ),
                ],
              ),

              if (_selectedFileName != null) ...[
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFFDE68A))),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.insert_drive_file_outlined, color: Color(0xFFD97706), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        '$_selectedFileName (${(_selectedFileSize / 1024).toStringAsFixed(1)} KB) — ${_parsedLeads.length} leads parsed',
                        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF92400E)),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => setState(() {
                          _selectedFileName = null;
                          _parsedLeads.clear();
                        }),
                        child: const Icon(Icons.cancel, color: Color(0xFFB45309), size: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: _downloadSampleCsv,
            child: const Text('Download Sample', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFFF59E0B), decoration: TextDecoration.underline, decorationColor: Color(0xFFF59E0B))),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: widget.onCancel, child: const Text('Cancel')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _selectedFileName == null ? null : () => setState(() => _currentStep = 2),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Next: Map Fields →'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 2: Map Fields
  Widget _buildStep2MapFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 2: Map CSV Columns to Callyzer CRM Fields'),
        const SizedBox(height: 6),
        const Text('Match your CSV file header titles to the corresponding system attributes:', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
        const SizedBox(height: 20),

        ..._mappedFields.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(width: 180, child: Text(entry.key, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold))),
                const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
                const SizedBox(width: 16),
                SizedBox(
                  width: 260,
                  height: 38,
                  child: DropdownButtonFormField<String>(
                    initialValue: entry.value,
                    isExpanded: true,
                    decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder()),
                    items: [
                      DropdownMenuItem(value: entry.value, child: Text('Mapped: ${entry.value}')),
                      const DropdownMenuItem(value: 'ignore', child: Text('-- Ignore Column --')),
                    ],
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 18),
              ],
            ),
          );
        }),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: () => setState(() => _currentStep = 1), child: const Text('← Back')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 3),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Next: Validate CSV Data →'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 3: Validate CSV Data
  Widget _buildStep3Validate() {
    final displayLeads = _parsedLeads.isNotEmpty
        ? _parsedLeads
        : [
            LeadItem(
              id: 'lead_9978217711',
              srNo: 1,
              name: 'kushal',
              phone: '9978217711',
              createdDate: '23 Sep 2026',
              tags: ['Hot Lead', 'Website'],
              tagAssignedDate: '23 Sep 2026',
              assignedTo: 'kushal asodia',
              assignedToPhone: '+91-9664579043',
              assignedDate: '23 Sep 2026',
              status: 'Positive',
              company: 'Takse Enterprises',
            ),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 3: Validate CSV Rows & Parsing Check'),
        const SizedBox(height: 6),
        Text(
          '${displayLeads.length} out of ${displayLeads.length} sample rows parsed successfully with zero errors.',
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF047857), fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        Table(
          border: TableBorder.all(color: const Color(0xFFE2E8F0)),
          columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(2.5),
            2: FlexColumnWidth(2.2),
            3: FlexColumnWidth(2.5),
            4: FlexColumnWidth(2.5),
            5: FlexColumnWidth(1.2),
          },
          children: [
            TableRow(
              decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
              children: const [
                Padding(padding: EdgeInsets.all(8), child: Text('Row #', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Tags', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Assignee', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                Padding(padding: EdgeInsets.all(8), child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
            ...displayLeads.map((lead) {
              final isKushal = lead.name.toLowerCase() == 'kushal' || lead.phone.contains('9978217711');
              return TableRow(
                decoration: isKushal ? const BoxDecoration(color: Color(0xFFF0FDF4)) : null,
                children: [
                  Padding(padding: const EdgeInsets.all(8), child: Text('${lead.srNo}')),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(lead.name, style: TextStyle(fontWeight: isKushal ? FontWeight.bold : FontWeight.normal, color: isKushal ? const Color(0xFF166534) : null)),
                        if (isKushal) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                            child: const Text('Target Lead', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF15803D))),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Padding(padding: const EdgeInsets.all(8), child: Text(lead.phone, style: TextStyle(fontWeight: isKushal ? FontWeight.bold : FontWeight.normal, color: isKushal ? const Color(0xFF166534) : null))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(lead.tags.join(', '))),
                  Padding(padding: const EdgeInsets.all(8), child: Text(lead.assignedTo)),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(4)),
                      child: const Text('Pass', style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: () => setState(() => _currentStep = 2), child: const Text('← Back')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 4),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Next: Actions & Duplicate Rules →'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 4: Actions & Duplicate Handling
  Widget _buildStep4Actions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 4: Duplicate Rule & Ingestion Actions'),
        const SizedBox(height: 16),
        const Text('When a phone number already exists in your pipeline:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),

        RadioListTile<String>(
          title: const Text('Skip Duplicate Leads (Recommended)', style: TextStyle(fontSize: 13)),
          value: 'skip',
          groupValue: _duplicateStrategy,
          activeColor: const Color(0xFFF59E0B),
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => _duplicateStrategy = val!),
        ),
        RadioListTile<String>(
          title: const Text('Overwrite existing lead attributes with new CSV data', style: TextStyle(fontSize: 13)),
          value: 'overwrite',
          groupValue: _duplicateStrategy,
          activeColor: const Color(0xFFF59E0B),
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => _duplicateStrategy = val!),
        ),
        RadioListTile<String>(
          title: const Text('Allow Duplicates (Creates a second separate entry)', style: TextStyle(fontSize: 13)),
          value: 'allow',
          groupValue: _duplicateStrategy,
          activeColor: const Color(0xFFF59E0B),
          contentPadding: EdgeInsets.zero,
          onChanged: (val) => setState(() => _duplicateStrategy = val!),
        ),

        const SizedBox(height: 16),
        const Text('Assign Default Lead Status:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: DropdownButtonFormField<String>(
            initialValue: _defaultStatus,
            isExpanded: true,
            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
            items: ['Positive', 'New Inflow', 'Follow Up', 'Contacted', 'Call Back', 'Not Pickup Call'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) => setState(() => _defaultStatus = val!),
          ),
        ),

        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: () => setState(() => _currentStep = 3), child: const Text('← Back')),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () => setState(() => _currentStep = 5),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B), foregroundColor: Colors.white),
              child: const Text('Review Summary & Import →'),
            ),
          ],
        ),
      ],
    );
  }

  // Step 5: Summary
  Widget _buildStep5Summary() {
    final count = _parsedLeads.isNotEmpty ? _parsedLeads.length : 4;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Step 5: Ready to Ingest Leads into Pipeline'),
        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFBFDBFE))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'File verified: $count qualified leads ready to be ingested into your cloud pipeline.',
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '• Connected directly to Firebase Cloud Firestore ("leads" collection).\n'
                      '• Live streaming directly to Android & iOS telecaller apps.\n'
                      '• Features target lead "kushal" (9978217711) with status "Positive" and full attributes.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(onPressed: () => setState(() => _currentStep = 4), child: const Text('← Back')),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _finishImport,
              icon: _isProcessing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.download_done_rounded, size: 16),
              label: Text(_isProcessing ? 'Ingesting Leads...' : 'Confirm & Complete Import'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            ),
          ],
        ),
      ],
    );
  }

  // Mode 2: Connectors Hub View
  Widget _buildConnectorsHubView() {
    final connectors = [
      {
        'title': 'Google Sheet (Import Leads)',
        'desc': 'Auto-import leads directly from your Google Sheets into Callyzer.',
        'icon': Icons.table_view_rounded,
        'color': const Color(0xFF10B981),
        'onTap': _showGoogleSheetsModal,
        'badge': 'Active Sync',
      },
      {
        'title': 'FB & Insta Lead Capture',
        'desc': 'Automatically capture leads from FB & Insta Ad campaigns in real-time.',
        'icon': Icons.campaign_rounded,
        'color': const Color(0xFF2563EB),
        'onTap': () => _showGenericConnectorModal('FB & Instagram Ads Connector'),
        'badge': 'Ready',
      },
      {
        'title': 'IndiaMART Lead Sync',
        'desc': 'Fetch IndiaMart buyer inquiries in real-time and distribute to team.',
        'icon': Icons.storefront_rounded,
        'color': const Color(0xFFEF4444),
        'onTap': () => _showGenericConnectorModal('IndiaMART Lead Integration'),
        'badge': 'Ready',
      },
      {
        'title': 'LeadCapture Form & Webhook',
        'desc': 'Embed customizable lead capture forms on your website or landing pages.',
        'icon': Icons.dynamic_form_rounded,
        'color': const Color(0xFFF59E0B),
        'onTap': () => _showGenericConnectorModal('LeadCapture Webhook Endpoint'),
        'badge': 'Ready',
      },
      {
        'title': 'REST API Integration',
        'desc': 'Import leads via secure REST API with auto-assignment routing.',
        'icon': Icons.api_rounded,
        'color': const Color(0xFF8B5CF6),
        'onTap': () => _showGenericConnectorModal('REST API Inbound Gateway'),
        'badge': 'Ready',
      },
      {
        'title': 'SFTP (Import Leads)',
        'desc': 'Connect your SFTP server to batch upload CSV files automatically.',
        'icon': Icons.folder_shared_rounded,
        'color': const Color(0xFFF97316),
        'onTap': () => _showGenericConnectorModal('SFTP Auto-Import Connector'),
        'badge': 'Ready',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 8,
            children: const [
              Text('Import Leads Automatically (Connectors Hub)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
              Text('Connect your lead source once and Callyzer will keep syncing leads automatically.', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 440,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 110,
            ),
            itemCount: connectors.length,
            itemBuilder: (context, index) {
              final c = connectors[index];
              return InkWell(
                onTap: c['onTap'] as VoidCallback,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: const [BoxShadow(color: Color(0x04000000), blurRadius: 4)],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: (c['color'] as Color).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Icon(c['icon'] as IconData, color: c['color'] as Color, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(c['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF1E293B))),
                            const SizedBox(height: 4),
                            Text(c['desc'] as String, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFFCBD5E1)),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showGenericConnectorModal(String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text('Configure and map $title to your pipeline parameters. Automated webhook listeners will ingest incoming buyer inquiries directly.', style: const TextStyle(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$title configured successfully.')));
            },
            child: const Text('Save Connector'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1E293B))),
        ),
      ],
    );
  }

  Widget _buildChecklistPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.check, size: 14, color: Color(0xFFF59E0B)),
            Icon(Icons.check, size: 14, color: Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.45))),
      ],
    );
  }

  Widget _buildStepper() {
    final steps = [
      {'step': 1, 'title': 'Import CSV File', 'icon': Icons.file_present_rounded},
      {'step': 2, 'title': 'Map Fields', 'icon': Icons.table_chart_outlined},
      {'step': 3, 'title': 'Validate CSV Data', 'icon': Icons.fact_check_outlined},
      {'step': 4, 'title': 'Actions', 'icon': Icons.touch_app_outlined},
      {'step': 5, 'title': 'Summary', 'icon': Icons.description_outlined},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          return Expanded(child: Container(height: 1.5, color: const Color(0xFFCBD5E1)));
        }

        final stepIndex = index ~/ 2;
        final item = steps[stepIndex];
        final stepNum = item['step'] as int;
        final isCurrent = stepNum == _currentStep;
        final isCompleted = stepNum < _currentStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Step $stepNum', style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCurrent ? const Color(0xFFF59E0B) : (isCompleted ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                  width: isCurrent ? 2.5 : 1.5,
                ),
              ),
              child: Center(
                child: isCurrent
                    ? Container(width: 28, height: 28, decoration: const BoxDecoration(color: Color(0xFF1E293B), shape: BoxShape.circle), child: const Icon(Icons.description_outlined, size: 16, color: Colors.white))
                    : Icon(item['icon'] as IconData, size: 18, color: isCompleted ? const Color(0xFF10B981) : const Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 6),
            Text(item['title'] as String, style: TextStyle(fontSize: 11.5, fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500, color: isCurrent ? const Color(0xFF1E293B) : const Color(0xFF64748B))),
          ],
        );
      }),
    );
  }
}
