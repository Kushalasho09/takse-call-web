import 'package:flutter/material.dart';
import '../models/dashboard_stats.dart';
import '../theme/app_colors.dart';
import 'stat_cell.dart';

class PeriodStatCard extends StatelessWidget {
  final PeriodData data;
  final VoidCallback? onCardTap;

  const PeriodStatCard({
    super.key,
    required this.data,
    this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Subtitle Date
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                data.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2-Column Metrics Grid
          // Row 1: Total Calls | Call Duration
          _buildRow(
            StatCell(
              value: '${data.totalCalls}',
              label: 'Total Calls',
              icon: Icons.phone_outlined,
            ),
            StatCell(
              value: data.callDuration,
              label: 'Call Duration',
              icon: Icons.access_time_rounded,
            ),
          ),
          const SizedBox(height: 8),

          // Row 2: Incoming | Incoming Duration (Green)
          _buildRow(
            StatCell(
              value: '${data.incoming}',
              label: 'Incoming',
              icon: Icons.call_received_rounded,
              color: AppColors.incoming,
            ),
            StatCell(
              value: data.incomingDuration,
              label: 'Incoming Duration',
              icon: Icons.access_time_rounded,
              color: AppColors.incoming,
            ),
          ),
          const SizedBox(height: 8),

          // Row 3: Outgoing | Outgoing Duration (Amber / Orange)
          _buildRow(
            StatCell(
              value: '${data.outgoing}',
              label: 'Outgoing',
              icon: Icons.call_made_rounded,
              color: AppColors.outgoing,
            ),
            StatCell(
              value: data.outgoingDuration,
              label: 'Outgoing Duration',
              icon: Icons.access_time_rounded,
              color: AppColors.outgoing,
            ),
          ),
          const SizedBox(height: 8),

          // Row 4: Missed | Rejected (Red)
          _buildRow(
            StatCell(
              value: '${data.missed}',
              label: 'Missed',
              icon: Icons.call_missed_rounded,
              color: AppColors.missed,
            ),
            StatCell(
              value: '${data.rejected}',
              label: 'Rejected',
              icon: Icons.block_flipped,
              color: AppColors.rejected,
            ),
          ),
          const SizedBox(height: 8),

          // Row 5: Never Attended | Not Pickup by Client (Coral)
          _buildRow(
            StatCell(
              value: '${data.neverAttended}',
              label: 'Never Attended',
              icon: Icons.phone_disabled_rounded,
              color: AppColors.neverAttended,
            ),
            StatCell(
              value: '${data.notPickupByClient}',
              label: 'Not Pickup by\nClient',
              icon: Icons.phone_missed_rounded,
              color: AppColors.notPickupByClient,
            ),
          ),
          const SizedBox(height: 8),

          // Row 6: Unique Clients | Working Hours
          _buildRow(
            StatCell(
              value: '${data.uniqueClients}',
              label: 'Unique Clients',
              icon: Icons.person_outline_rounded,
            ),
            StatCell(
              value: data.workingHours,
              label: 'Working Hours',
              icon: Icons.hourglass_empty_rounded,
            ),
          ),
          const SizedBox(height: 8),

          // Row 7: Connected Calls | Empty Spacer
          _buildRow(
            StatCell(
              value: '${data.connectedCalls}',
              label: 'Connected Calls',
              icon: Icons.phone_in_talk_rounded,
            ),
            const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(Widget left, Widget right) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 8),
        Expanded(child: right),
      ],
    );
  }
}
