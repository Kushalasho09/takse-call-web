import 'package:intl/intl.dart';
import '../models/dashboard_stats.dart';

class StatsDataService {
  static String formatDuration(int totalSeconds) {
    if (totalSeconds <= 0) return '-';
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours}h ${minutes}m ${seconds}s';
  }

  static String getTodaySubtitle() {
    return DateFormat('d MMM yyyy').format(DateTime.now());
  }

  static String getYesterdaySubtitle() {
    return DateFormat('d MMM yyyy').format(DateTime.now().subtract(const Duration(days: 1)));
  }

  static String getLastWeekSubtitle() {
    final now = DateTime.now();
    final end = now.subtract(const Duration(days: 1));
    final start = now.subtract(const Duration(days: 7));
    return '${DateFormat('d').format(start)} to ${DateFormat('d MMM yyyy').format(end)}';
  }

  static PeriodData empty(String title, String subtitle) {
    return PeriodData(
      title: title,
      subtitle: subtitle,
      totalCalls: 0,
      callDuration: '-',
      incoming: 0,
      incomingDuration: '-',
      outgoing: 0,
      outgoingDuration: '-',
      missed: 0,
      rejected: 0,
      neverAttended: 0,
      notPickupByClient: 0,
      uniqueClients: 0,
      workingHours: '-',
      connectedCalls: 0,
    );
  }

  static PeriodData getTodayStats({bool withSampleData = false}) {
    if (withSampleData) {
      return PeriodData(
        title: 'Today',
        subtitle: getTodaySubtitle(),
        totalCalls: 3,
        callDuration: '0h 0m 45s',
        incoming: 1,
        incomingDuration: '0h 0m 30s',
        outgoing: 2,
        outgoingDuration: '0h 0m 15s',
        missed: 0,
        rejected: 0,
        neverAttended: 0,
        notPickupByClient: 0,
        uniqueClients: 2,
        workingHours: '0h 2m 10s',
        connectedCalls: 2,
      );
    }
    return empty('Today', getTodaySubtitle());
  }

  static PeriodData getYesterdayStats({bool withSampleData = false}) {
    if (withSampleData) {
      return PeriodData(
        title: 'Yesterday',
        subtitle: getYesterdaySubtitle(),
        totalCalls: 5,
        callDuration: '0h 1m 12s',
        incoming: 1,
        incomingDuration: '0h 0m 7s',
        outgoing: 4,
        outgoingDuration: '0h 1m 5s',
        missed: 0,
        rejected: 0,
        neverAttended: 0,
        notPickupByClient: 1,
        uniqueClients: 3,
        workingHours: '0h 4m 29s',
        connectedCalls: 2,
      );
    }
    return empty('Yesterday', getYesterdaySubtitle());
  }

  static PeriodData getLastWeekStats({bool withSampleData = false}) {
    if (withSampleData) {
      return PeriodData(
        title: 'Last Week',
        subtitle: getLastWeekSubtitle(),
        totalCalls: 11,
        callDuration: '0h 1m 46s',
        incoming: 2,
        incomingDuration: '0h 0m 41s',
        outgoing: 7,
        outgoingDuration: '0h 1m 5s',
        missed: 1,
        rejected: 1,
        neverAttended: 0,
        notPickupByClient: 2,
        uniqueClients: 4,
        workingHours: '0h 9m 34s',
        connectedCalls: 3,
      );
    }
    return empty('Last Week', getLastWeekSubtitle());
  }
}
