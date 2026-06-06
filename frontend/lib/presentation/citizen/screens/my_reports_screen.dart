import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/incident_model.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_state.dart';

class MyReportsScreen extends StatelessWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CitizenBloc, CitizenState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('My Reports', style: AppTextStyles.headlineSmall),
                      Text(
                        '${state.reports.length} total report${state.reports.length == 1 ? '' : 's'}',
                        style: AppTextStyles.bodySmall.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  if (state.reports.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Text('AI confidence',
                                style: AppTextStyles.bodySmall),
                            const SizedBox(width: 4),
                            const Icon(Icons.smart_toy_outlined,
                                color: AppColors.primary, size: 16),
                          ],
                        ),
                        Text(
                          'Pending',
                          style: AppTextStyles.headlineSmall
                              .copyWith(color: AppColors.primary, fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (state.reports.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Reports',
                        style: AppTextStyles.titleLarge
                            .copyWith(color: AppColors.primary)),
                    Text('Most Recent',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textPrimary)),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              Expanded(
                child: state.reports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_outlined,
                                color: AppColors.textMuted, size: 48),
                            const SizedBox(height: 16),
                            Text('No reports yet',
                                style: AppTextStyles.headlineSmall
                                    .copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to submit your first report',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: state.reports.length,
                        separatorBuilder: (context, i) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, i) =>
                            _ReportCard(incident: state.reports[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final IncidentModel incident;
  const _ReportCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    final isOngoing = incident.status == IncidentStatus.ongoing;
    final statusColor = isOngoing ? AppColors.high : AppColors.medium;
    final statusLabel = isOngoing ? 'Ongoing' : 'Resolved';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image area
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getIcon(incident.title),
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text(
                    'ID: ${incident.id}',
                    style: AppTextStyles.labelMedium,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 4),
                Text(incident.timeAgo, style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        color: AppColors.medium, size: 14),
                    const SizedBox(width: 4),
                    Text(incident.sector, style: AppTextStyles.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String title) {
    if (title.toLowerCase().contains('noise')) return Icons.volume_up;
    if (title.toLowerCase().contains('infra')) return Icons.construction;
    if (title.toLowerCase().contains('fire')) return Icons.local_fire_department;
    if (title.toLowerCase().contains('car')) return Icons.car_crash;
    return Icons.warning_amber;
  }
}
