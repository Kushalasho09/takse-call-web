import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/dashboard_stats.dart';
import 'stats_data_service.dart';
import 'web_auth_service.dart';

class WebCallLog {
  final String id;
  final String connectCode;
  final String employeeName;
  final String employeePhone;
  final String clientName;
  final String clientNumber;
  final String type; // incoming, outgoing, missed, rejected
  final int durationSeconds;
  final DateTime timestamp;
  final String simSlot;
  final String? tag;
  final String? note;

  WebCallLog({
    required this.id,
    required this.connectCode,
    required this.employeeName,
    required this.employeePhone,
    required this.clientName,
    required this.clientNumber,
    required this.type,
    required this.durationSeconds,
    required this.timestamp,
    required this.simSlot,
    this.tag,
    this.note,
  });

  factory WebCallLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final ts = data['timestamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(data['timestamp'] is int ? data['timestamp'] : int.tryParse(data['timestamp'].toString()) ?? 0)
        : DateTime.now();

    return WebCallLog(
      id: doc.id,
      connectCode: data['connectCode'] ?? '',
      employeeName: data['employeeName'] ?? 'Agent',
      employeePhone: data['employeePhone'] ?? '',
      clientName: data['name'] ?? data['number'] ?? 'Unknown',
      clientNumber: data['number'] ?? '',
      type: data['type'] ?? 'incoming',
      durationSeconds: data['duration'] is int ? data['duration'] : int.tryParse(data['duration']?.toString() ?? '0') ?? 0,
      timestamp: ts,
      simSlot: data['simSlot'] ?? 'SIM 1',
      tag: data['tag'],
      note: data['note'],
    );
  }
}

class FirestoreDevice {
  final String connectCode;
  final String userName;
  final String userPhone;
  final String companyName;
  final String status; // 'active' or 'pending'
  final String? deviceModel;
  final DateTime? lastSyncAt;
  final int totalCallsCount;

  FirestoreDevice({
    required this.connectCode,
    required this.userName,
    required this.userPhone,
    required this.companyName,
    required this.status,
    this.deviceModel,
    this.lastSyncAt,
    this.totalCallsCount = 0,
  });

  factory FirestoreDevice.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    DateTime? lastSync;
    if (data['lastSyncAt'] is Timestamp) {
      lastSync = (data['lastSyncAt'] as Timestamp).toDate();
    }

    return FirestoreDevice(
      connectCode: doc.id,
      userName: data['userName'] ?? data['name'] ?? 'Agent',
      userPhone: data['userPhone'] ?? data['phone'] ?? '',
      companyName: data['companyName'] ?? '',
      status: data['status'] ?? 'pending',
      deviceModel: data['deviceModel'],
      lastSyncAt: lastSync,
      totalCallsCount: data['totalCallsCount'] ?? 0,
    );
  }
}

class FirestoreSyncService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream real-time call logs for the logged-in user or their organization
  static Stream<List<WebCallLog>> streamCallLogs({String? filterConnectCode}) {
    final code = filterConnectCode ?? WebAuthService.currentUser?.connectCode;
    
    Query query = _firestore.collection('call_logs');
    if (code != null && code.isNotEmpty) {
      final cleanCode = code.replaceAll('-', '');
      final codes = {code, cleanCode}.toList();
      query = query.where('connectCode', whereIn: codes);
    }
    
    return query.snapshots().map((snapshot) {
      final list = snapshot.docs.map((doc) => WebCallLog.fromFirestore(doc)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    }).handleError((err) {
      debugPrint('Firestore streamCallLogs notice: $err');
      return <WebCallLog>[];
    });
  }

  /// Stream real-time connected employee devices
  static Stream<List<FirestoreDevice>> streamDevices() {
    return _firestore.collection('devices').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => FirestoreDevice.fromFirestore(doc)).toList();
    }).handleError((err) {
      debugPrint('Firestore streamDevices notice: $err');
      return <FirestoreDevice>[];
    });
  }

  /// Computes live PeriodData (Today, Yesterday, Last Week) from streaming Firestore call logs
  static PeriodData computePeriodData(List<WebCallLog> allLogs, String period) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final tomorrowStart = todayStart.add(const Duration(days: 1));
    final yesterdayStart = todayStart.subtract(const Duration(days: 1));
    final lastWeekStart = todayStart.subtract(const Duration(days: 7));

    List<WebCallLog> periodLogs = [];
    String subtitle = '';

    if (period == 'Today') {
      subtitle = DateFormat('d MMM yyyy').format(now);
      periodLogs = allLogs.where((l) => !l.timestamp.isBefore(todayStart) && l.timestamp.isBefore(tomorrowStart)).toList();
    } else if (period == 'Yesterday') {
      subtitle = DateFormat('d MMM yyyy').format(yesterdayStart);
      periodLogs = allLogs.where((l) => !l.timestamp.isBefore(yesterdayStart) && l.timestamp.isBefore(todayStart)).toList();
    } else {
      // Last Week
      final end = yesterdayStart;
      final start = lastWeekStart;
      subtitle = '${DateFormat('d').format(start)} to ${DateFormat('d MMM yyyy').format(end)}';
      periodLogs = allLogs.where((l) => !l.timestamp.isBefore(lastWeekStart) && l.timestamp.isBefore(todayStart)).toList();
    }

    if (periodLogs.isEmpty) {
      return StatsDataService.empty(period, subtitle);
    }

    int totalCalls = periodLogs.length;
    int totalDuration = 0;
    int incoming = 0;
    int incomingDuration = 0;
    int outgoing = 0;
    int outgoingDuration = 0;
    int missed = 0;
    int rejected = 0;
    int connectedCalls = 0;
    final Set<String> uniqueNumbers = {};

    for (var log in periodLogs) {
      uniqueNumbers.add(log.clientNumber);
      totalDuration += log.durationSeconds;

      final type = log.type.toLowerCase();
      if (type.contains('incoming')) {
        incoming++;
        incomingDuration += log.durationSeconds;
        if (log.durationSeconds > 0) connectedCalls++;
      } else if (type.contains('outgoing')) {
        outgoing++;
        outgoingDuration += log.durationSeconds;
        if (log.durationSeconds > 0) connectedCalls++;
      } else if (type.contains('missed')) {
        missed++;
      } else if (type.contains('rejected')) {
        rejected++;
      }
    }

    return PeriodData(
      title: period,
      subtitle: subtitle,
      totalCalls: totalCalls,
      callDuration: StatsDataService.formatDuration(totalDuration),
      incoming: incoming,
      incomingDuration: StatsDataService.formatDuration(incomingDuration),
      outgoing: outgoing,
      outgoingDuration: StatsDataService.formatDuration(outgoingDuration),
      missed: missed,
      rejected: rejected,
      neverAttended: 0,
      notPickupByClient: 0,
      uniqueClients: uniqueNumbers.length,
      workingHours: StatsDataService.formatDuration(totalDuration + (totalCalls * 15)),
      connectedCalls: connectedCalls,
    );
  }
}
