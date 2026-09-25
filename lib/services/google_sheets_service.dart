import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lead_item.dart';
import 'web_lead_firestore_service.dart';

class GoogleSheetConfig {
  final String spreadsheetId;
  final String sheetUrl;
  final String apiKey;
  final String range;
  final String distributionMode; // 'round_robin', 'single', 'none'
  final List<String> assignedAgents;
  final int syncFrequencyMinutes;
  final DateTime? lastSyncAt;
  final int totalSyncedCount;
  final String status;

  GoogleSheetConfig({
    required this.spreadsheetId,
    required this.sheetUrl,
    required this.apiKey,
    this.range = 'Sheet1!A1:Z500',
    this.distributionMode = 'round_robin',
    this.assignedAgents = const [],
    this.syncFrequencyMinutes = 5,
    this.lastSyncAt,
    this.totalSyncedCount = 0,
    this.status = 'active',
  });

  Map<String, dynamic> toMap() {
    return {
      'spreadsheetId': spreadsheetId,
      'sheetUrl': sheetUrl,
      'apiKey': apiKey,
      'range': range,
      'distributionMode': distributionMode,
      'assignedAgents': assignedAgents,
      'syncFrequencyMinutes': syncFrequencyMinutes,
      'lastSyncAt': lastSyncAt != null ? Timestamp.fromDate(lastSyncAt!) : null,
      'totalSyncedCount': totalSyncedCount,
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory GoogleSheetConfig.fromMap(Map<String, dynamic> map) {
    DateTime? lastSync;
    if (map['lastSyncAt'] is Timestamp) {
      lastSync = (map['lastSyncAt'] as Timestamp).toDate();
    }
    return GoogleSheetConfig(
      spreadsheetId: map['spreadsheetId'] ?? '',
      sheetUrl: map['sheetUrl'] ?? '',
      apiKey: map['apiKey'] ?? '',
      range: map['range'] ?? 'Sheet1!A1:Z500',
      distributionMode: map['distributionMode'] ?? 'round_robin',
      assignedAgents: (map['assignedAgents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      syncFrequencyMinutes: map['syncFrequencyMinutes'] ?? 5,
      lastSyncAt: lastSync,
      totalSyncedCount: map['totalSyncedCount'] ?? 0,
      status: map['status'] ?? 'active',
    );
  }
}

class GoogleSheetsService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Extracts the clean Google Spreadsheet ID from a link or raw string.
  /// Example input: https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit#gid=0
  /// Output: 1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms
  static String extractSpreadsheetId(String input) {
    final clean = input.trim();
    if (!clean.contains('/')) return clean;

    final regExp = RegExp(r'/spreadsheets/d/([a-zA-Z0-9-_]+)');
    final match = regExp.firstMatch(clean);
    if (match != null && match.groupCount >= 1) {
      return match.group(1)!;
    }
    return clean;
  }

  /// Fetches sheet rows using Google Sheets API v4 with a Google Cloud API Key
  /// Endpoint: https://sheets.googleapis.com/v4/spreadsheets/{spreadsheetId}/values/{range}?key={apiKey}
  static Future<List<List<String>>> fetchSheetWithApiKey({
    required String spreadsheetId,
    required String apiKey,
    String range = 'Sheet1!A1:Z1000',
  }) async {
    final cleanId = extractSpreadsheetId(spreadsheetId);
    final encodedRange = Uri.encodeComponent(range.isNotEmpty ? range : 'Sheet1!A1:Z1000');
    final uri = Uri.parse('https://sheets.googleapis.com/v4/spreadsheets/$cleanId/values/$encodedRange?key=$apiKey');

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final rawValues = json['values'] as List<dynamic>?;
      if (rawValues == null || rawValues.isEmpty) {
        return [];
      }

      return rawValues.map((row) {
        if (row is List) {
          return row.map((cell) => cell?.toString() ?? '').toList();
        }
        return <String>[];
      }).toList();
    } else {
      String errMessage = 'Failed to fetch sheet (HTTP ${response.statusCode})';
      try {
        final errJson = jsonDecode(response.body);
        if (errJson['error']?['message'] != null) {
          errMessage = errJson['error']['message'];
        }
      } catch (_) {}
      throw Exception(errMessage);
    }
  }

  /// Fallback: Fetches public Google Sheet data via CSV export (no API Key required if shared via link)
  static Future<List<List<String>>> fetchSheetViaCsvExport({
    required String spreadsheetId,
  }) async {
    final cleanId = extractSpreadsheetId(spreadsheetId);
    final uri = Uri.parse('https://docs.google.com/spreadsheets/d/$cleanId/export?format=csv');

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return parseCsvString(response.body);
    } else {
      throw Exception('Could not access sheet via public link. Please verify sharing is set to "Anyone with link can view" or use a Google Cloud API Key.');
    }
  }

  /// Parses CSV text format into 2D row/column list
  static List<List<String>> parseCsvString(String rawCsv) {
    final lines = rawCsv.split(RegExp(r'\r?\n'));
    final result = <List<String>>[];

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;
      result.add(_parseCsvLine(trimmed));
    }
    return result;
  }

  static List<String> _parseCsvLine(String line) {
    final List<String> cells = [];
    final StringBuffer currentCell = StringBuffer();
    bool inQuotes = false;

    for (int i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          currentCell.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        cells.add(currentCell.toString().trim());
        currentCell.clear();
      } else {
        currentCell.write(char);
      }
    }
    cells.add(currentCell.toString().trim());
    return cells;
  }

  /// Smart column mapper that converts 2D sheet rows into LeadItem models
  static List<LeadItem> convertRowsToLeads(
    List<List<String>> rows, {
    String defaultStatus = 'Positive',
    String? defaultAssignee,
    List<String> roundRobinAgents = const [],
  }) {
    if (rows.length < 2) return [];

    final headers = rows.first.map((h) => h.trim().toLowerCase()).toList();

    int idxName = headers.indexWhere((h) => h.contains('name') || h.contains('customer') || h.contains('client'));
    int idxPhone = headers.indexWhere((h) => h.contains('phone') || h.contains('contact') || h.contains('mobile') || h.contains('number'));
    int idxAltPhone = headers.indexWhere((h) => h.contains('alternate') || h.contains('alt') || h.contains('secondary'));
    int idxCompany = headers.indexWhere((h) => h.contains('company') || h.contains('org') || h.contains('business'));
    int idxEmail = headers.indexWhere((h) => h.contains('email') || h.contains('mail'));
    int idxAddress = headers.indexWhere((h) => h.contains('address'));
    int idxCity = headers.indexWhere((h) => h.contains('city'));
    int idxState = headers.indexWhere((h) => h.contains('state'));
    int idxPincode = headers.indexWhere((h) => h.contains('pin') || h.contains('zip'));
    int idxStatus = headers.indexWhere((h) => h.contains('status') || h.contains('stage'));
    int idxAssignTo = headers.indexWhere((h) => h.contains('assign') || h.contains('telecaller') || h.contains('agent') || h.contains('owner'));
    int idxTags = headers.indexWhere((h) => h.contains('tag') || h.contains('source'));
    int idxNotes = headers.indexWhere((h) => h.contains('note') || h.contains('desc') || h.contains('remark'));
    int idxPrice = headers.indexWhere((h) => h.contains('price') || h.contains('amount') || h.contains('deal') || h.contains('budget') || h.contains('value'));

    final List<LeadItem> leads = [];
    int agentPointer = 0;

    for (int r = 1; r < rows.length; r++) {
      final row = rows[r];
      if (row.isEmpty) continue;

      String getVal(int idx) {
        if (idx >= 0 && idx < row.length) {
          return row[idx].trim();
        }
        return '';
      }

      final rawName = getVal(idxName);
      final rawPhone = getVal(idxPhone);

      // Skip row if both name and phone are empty
      if (rawName.isEmpty && rawPhone.isEmpty) continue;

      final name = rawName.isNotEmpty ? rawName : 'Lead $r';
      final phone = rawPhone.isNotEmpty ? rawPhone : '9000000000';
      final cleanDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
      final leadId = 'lead_${cleanDigits.isNotEmpty ? cleanDigits : DateTime.now().millisecondsSinceEpoch}_$r';

      // Assignee logic: from sheet, or round-robin, or default
      String assignedTo = getVal(idxAssignTo);
      if (assignedTo.isEmpty) {
        if (roundRobinAgents.isNotEmpty) {
          assignedTo = roundRobinAgents[agentPointer % roundRobinAgents.length];
          agentPointer++;
        } else if (defaultAssignee != null && defaultAssignee.isNotEmpty) {
          assignedTo = defaultAssignee;
        } else {
          assignedTo = 'kushal asodia (+91-9664579043)';
        }
      }

      String assignedName = assignedTo;
      String assignedPhone = '+91-9664579043';
      if (assignedTo.contains('(')) {
        final parts = assignedTo.split('(');
        assignedName = parts[0].trim();
        assignedPhone = parts[1].replaceAll(')', '').trim();
      }

      // Status
      String status = getVal(idxStatus);
      if (status.isEmpty) status = defaultStatus;

      // Tags
      final rawTags = getVal(idxTags);
      List<String> tags = ['Google Sheet'];
      if (rawTags.isNotEmpty) {
        tags = rawTags.split(RegExp(r'[;,]')).map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
        if (!tags.contains('Google Sheet')) tags.add('Google Sheet');
      }

      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

      leads.add(
        LeadItem(
          id: leadId,
          srNo: r,
          leadNumber: r,
          name: name,
          phone: phone,
          altPhone: getVal(idxAltPhone).isNotEmpty ? getVal(idxAltPhone) : null,
          createdDate: '$dateStr, 12:00 PM',
          attempts: 0,
          tags: tags,
          tagAssignedDate: dateStr,
          assignedTo: assignedName,
          assignedToPhone: assignedPhone,
          assignedDate: '$dateStr | 12:00 PM',
          status: status,
          company: getVal(idxCompany).isNotEmpty ? getVal(idxCompany) : 'Individual',
          email: getVal(idxEmail).isNotEmpty ? getVal(idxEmail) : null,
          address1: getVal(idxAddress).isNotEmpty ? getVal(idxAddress) : null,
          city: getVal(idxCity).isNotEmpty ? getVal(idxCity) : null,
          state: getVal(idxState).isNotEmpty ? getVal(idxState) : null,
          zipcode: getVal(idxPincode).isNotEmpty ? getVal(idxPincode) : null,
          description: getVal(idxNotes).isNotEmpty ? getVal(idxNotes) : null,
          source: 'Google Sheet',
          price: getVal(idxPrice).isNotEmpty ? getVal(idxPrice) : '₹ 0',
        ),
      );
    }

    return leads;
  }

  /// Saves the Google Sheet Connector configuration to Firestore
  static Future<void> saveConnectorConfig(GoogleSheetConfig config) async {
    try {
      await _firestore.collection('connectors').doc('google_sheets').set(
        config.toMap(),
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error saving Google Sheet connector config: $e');
    }
  }

  /// Streams or fetches current Google Sheet connector configuration
  static Future<GoogleSheetConfig?> getConnectorConfig() async {
    try {
      final doc = await _firestore.collection('connectors').doc('google_sheets').get();
      if (doc.exists && doc.data() != null) {
        return GoogleSheetConfig.fromMap(doc.data()!);
      }
    } catch (e) {
      debugPrint('Error loading Google Sheet config: $e');
    }
    return null;
  }

  /// Full automated sync: fetches sheet, converts to leads, and pushes to Firestore
  static Future<int> syncSheetToPipeline({
    required String spreadsheetId,
    String? apiKey,
    String range = 'Sheet1!A1:Z1000',
    String distributionMode = 'round_robin',
    List<String> assignedAgents = const [],
  }) async {
    List<List<String>> rows;

    if (apiKey != null && apiKey.trim().isNotEmpty) {
      rows = await fetchSheetWithApiKey(
        spreadsheetId: spreadsheetId,
        apiKey: apiKey.trim(),
        range: range,
      );
    } else {
      rows = await fetchSheetViaCsvExport(
        spreadsheetId: spreadsheetId,
      );
    }

    if (rows.length < 2) return 0;

    final leads = convertRowsToLeads(
      rows,
      roundRobinAgents: assignedAgents,
    );

    for (final lead in leads) {
      await WebLeadFirestoreService.saveLead(lead);
    }

    // Update connector sync stats in Firestore
    await saveConnectorConfig(
      GoogleSheetConfig(
        spreadsheetId: extractSpreadsheetId(spreadsheetId),
        sheetUrl: spreadsheetId.contains('http') ? spreadsheetId : 'https://docs.google.com/spreadsheets/d/${extractSpreadsheetId(spreadsheetId)}',
        apiKey: apiKey ?? '',
        range: range,
        distributionMode: distributionMode,
        assignedAgents: assignedAgents,
        lastSyncAt: DateTime.now(),
        totalSyncedCount: leads.length,
        status: 'active',
      ),
    );

    return leads.length;
  }
}
