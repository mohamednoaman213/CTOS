import 'package:cached_network_image/cached_network_image.dart';
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
    final statusLabel = _statusLabel(incident.status);
    final statusColor = _statusColor(incident.status);

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
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: incident.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: incident.imageUrl!,
                          width: double.infinity,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Center(
                            child: CircularProgressIndicator(
                                color: AppColors.primary, strokeWidth: 2),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Icon(_getIcon(incident.title),
                                size: 48, color: AppColors.textMuted),
                          ),
                        )
                      : Center(
                          child: Icon(_getIcon(incident.title),
                              size: 48, color: AppColors.textMuted),
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
                const SizedBox(height: 10),
                // AI analysis row
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    // Category chips from AI labels
                    if (incident.sector.isNotEmpty && incident.sector != 'General')
                      ..._categoryChips(incident.sector),
                    // Priority badge
                    _priorityBadge(incident.priority),
                    // AI validity
                    _aiBadge(incident.aiVerified),
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

  String _statusLabel(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.ongoing: return 'Officer Assigned';
      case IncidentStatus.resolved: return 'Resolved';
      case IncidentStatus.pending: return 'Under Processing';
      case IncidentStatus.live: return 'Live';
    }
  }

  Color _statusColor(IncidentStatus status) {
    switch (status) {
      case IncidentStatus.ongoing: return AppColors.high;
      case IncidentStatus.resolved: return AppColors.medium;
      case IncidentStatus.pending: return AppColors.primary;
      case IncidentStatus.live: return AppColors.critical;
    }
  }

  List<Widget> _categoryChips(String sector) {
    return sector.split(',').map((label) {
      final l = label.trim().toUpperCase();
      final color = l.contains('FIRE') ? AppColors.critical
          : (l.contains('PISTOL') || l.contains('KNIFE')) ? AppColors.high
          : AppColors.primary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(l,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      );
    }).toList();
  }

  Widget _priorityBadge(IncidentPriority priority) {
    final (label, color) = switch (priority) {
      IncidentPriority.critical => ('CRITICAL', AppColors.critical),
      IncidentPriority.high     => ('HIGH', AppColors.high),
      IncidentPriority.medium   => ('MEDIUM', AppColors.medium),
      IncidentPriority.low      => ('LOW', AppColors.textMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.shield_outlined, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _aiBadge(bool valid) {
    final color = valid ? AppColors.onlineGreen : AppColors.textMuted;
    final label = valid ? 'THREAT DETECTED' : 'NO THREAT';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.smart_toy_outlined, color: color, size: 11),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 10, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
