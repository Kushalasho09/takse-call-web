class PeriodData {
  final String title;
  final String subtitle;
  final int totalCalls;
  final String callDuration;
  final int incoming;
  final String incomingDuration;
  final int outgoing;
  final String outgoingDuration;
  final int missed;
  final int rejected;
  final int neverAttended;
  final int notPickupByClient;
  final int uniqueClients;
  final String workingHours;
  final int connectedCalls;

  const PeriodData({
    required this.title,
    required this.subtitle,
    required this.totalCalls,
    required this.callDuration,
    required this.incoming,
    required this.incomingDuration,
    required this.outgoing,
    required this.outgoingDuration,
    required this.missed,
    required this.rejected,
    required this.neverAttended,
    required this.notPickupByClient,
    required this.uniqueClients,
    required this.workingHours,
    required this.connectedCalls,
  });

  PeriodData copyWith({
    String? title,
    String? subtitle,
    int? totalCalls,
    String? callDuration,
    int? incoming,
    String? incomingDuration,
    int? outgoing,
    String? outgoingDuration,
    int? missed,
    int? rejected,
    int? neverAttended,
    int? notPickupByClient,
    int? uniqueClients,
    String? workingHours,
    int? connectedCalls,
  }) {
    return PeriodData(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      totalCalls: totalCalls ?? this.totalCalls,
      callDuration: callDuration ?? this.callDuration,
      incoming: incoming ?? this.incoming,
      incomingDuration: incomingDuration ?? this.incomingDuration,
      outgoing: outgoing ?? this.outgoing,
      outgoingDuration: outgoingDuration ?? this.outgoingDuration,
      missed: missed ?? this.missed,
      rejected: rejected ?? this.rejected,
      neverAttended: neverAttended ?? this.neverAttended,
      notPickupByClient: notPickupByClient ?? this.notPickupByClient,
      uniqueClients: uniqueClients ?? this.uniqueClients,
      workingHours: workingHours ?? this.workingHours,
      connectedCalls: connectedCalls ?? this.connectedCalls,
    );
  }
}
