import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/incident_model.dart';
import '../../shared/widgets/priority_badge.dart';
import '../bloc/officer_bloc.dart';
import '../bloc/officer_event.dart';
import '../bloc/officer_state.dart';

class OfficerDashboardScreen extends StatefulWidget {
  const OfficerDashboardScreen({super.key});

  @override
  State<OfficerDashboardScreen> createState() => _OfficerDashboardScreenState();
}

class _OfficerDashboardScreenState extends State<OfficerDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OfficerBloc>().add(LoadOfficerDataEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfficerBloc, OfficerState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Stats row
              Row(
                children: [
                  _StatChip(
                    label: 'UNITS ACTIVE',
                    value: '${state.unitsActive}',
                    delta: '+2',
                    icon: Icons.local_police_outlined,
                    iconColor: AppColors.medium,
                  ),
                  const SizedBox(width: 12),
                  _StatChip(
                    label: 'REPORTS ON QUEUE',
                    value: '${state.incidents.length}',
                    badge: state.incidents.isEmpty ? 'No Reports' : null,
                    icon: Icons.assignment_outlined,
                    iconColor: AppColors.high,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.sensors, color: AppColors.primary, size: 16),
                      const SizedBox(width: 4),
                      const Text('Live Feed',
                          style: AppTextStyles.headlineSmall),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('SORT BY: ', style: AppTextStyles.bodySmall),
                      const Text('Highest Priority',
                          style: TextStyle(
                              color: AppColors.textPrimary, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: state.incidents.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assignment_outlined,
                                color: AppColors.textMuted, size: 52),
                            const SizedBox(height: 16),
                            Text('No citizen reports yet',
                                style: AppTextStyles.headlineSmall
                                    .copyWith(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text(
                              'Reports submitted by citizens will appear here',
                              style: AppTextStyles.bodySmall,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: state.incidents.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) =>
                            _IncidentCard(incident: state.incidents[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String? delta;
  final String? badge;
  final IconData icon;
  final Color iconColor;

  const _StatChip({
    required this.label,
    required this.value,
    this.delta,
    this.badge,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.bodySmall.copyWith(fontSize: 9)),
                ),
                Icon(icon, color: iconColor, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: AppTextStyles.headlineLarge),
                if (delta != null) ...[
                  const SizedBox(width: 4),
                  Text(delta!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.medium)),
                ],
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.medium.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(badge!,
                        style: const TextStyle(
                            color: AppColors.medium,
                            fontSize: 9,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  const _IncidentCard({required this.incident});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    _getIcon(incident.title),
                    size: 40,
                    color: AppColors.textMuted.withValues(alpha: 0.4),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: PriorityBadge.fromPriority(incident.priority),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Text('ID: ${incident.id}',
                      style: AppTextStyles.labelMedium),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(incident.title, style: AppTextStyles.headlineSmall),
                const SizedBox(height: 3),
                Text(incident.location, style: AppTextStyles.bodySmall),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.medium, size: 12),
                    const SizedBox(width: 4),
                    Text('AI Verified',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.medium)),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context
                          .read<OfficerBloc>()
                          .add(AssignIncidentEvent(incident.id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Report #${incident.id} assigned to officer'),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.assignment_ind_outlined, size: 16),
                    label: const Text('ASSIGN TO OFFICER',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String title) {
    final t = title.toLowerCase();
    if (t.contains('chemical')) return Icons.science_outlined;
    if (t.contains('riot')) return Icons.groups_outlined;
    if (t.contains('fire')) return Icons.local_fire_department_outlined;
    if (t.contains('car')) return Icons.car_crash_outlined;
    if (t.contains('noise')) return Icons.volume_up_outlined;
    return Icons.construction_outlined;
  }
}
