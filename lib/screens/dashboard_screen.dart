import 'package:flutter/material.dart';
import '../services/firestore_sync_service.dart';
import '../widgets/period_stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _useLiveDemoData = false;

  void _toggleLiveSimulation() {
    setState(() {
      _useLiveDemoData = !_useLiveDemoData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<WebCallLog>>(
      stream: FirestoreSyncService.streamCallLogs(),
      builder: (context, snapshot) {
        final logs = snapshot.data ?? [];

        final todayStats = FirestoreSyncService.computePeriodData(logs, 'Today');
        final yesterdayStats = FirestoreSyncService.computePeriodData(logs, 'Yesterday');
        final lastWeekStats = FirestoreSyncService.computePeriodData(logs, 'Last Week');

        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 3 Period Cards (Today, Yesterday, Last Week) matching reference UI
                  if (screenWidth >= 1080)
                    // Desktop: 3-column equal grid
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PeriodStatCard(
                            data: todayStats,
                            onCardTap: _toggleLiveSimulation,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: PeriodStatCard(
                            data: yesterdayStats,
                          ),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: PeriodStatCard(
                            data: lastWeekStats,
                          ),
                        ),
                      ],
                    )
                  else if (screenWidth >= 720)
                    // Tablet: 2-columns top + 1 bottom
                    Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: PeriodStatCard(
                                data: todayStats,
                                onCardTap: _toggleLiveSimulation,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: PeriodStatCard(
                                data: yesterdayStats,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PeriodStatCard(
                          data: lastWeekStats,
                        ),
                      ],
                    )
                  else
                    // Mobile: 1-column stacked
                    Column(
                      children: [
                        PeriodStatCard(
                          data: todayStats,
                          onCardTap: _toggleLiveSimulation,
                        ),
                        const SizedBox(height: 16),
                        PeriodStatCard(
                          data: yesterdayStats,
                        ),
                        const SizedBox(height: 16),
                        PeriodStatCard(
                          data: lastWeekStats,
                        ),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

