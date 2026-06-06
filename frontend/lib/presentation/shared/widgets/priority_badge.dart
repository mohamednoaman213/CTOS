import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/notification_model.dart';

class PriorityBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool pulsing;

  const PriorityBadge({
    super.key,
    required this.label,
    required this.color,
    this.pulsing = false,
  });

  factory PriorityBadge.fromPriority(IncidentPriority priority) {
    switch (priority) {
      case IncidentPriority.critical:
        return const PriorityBadge(
          label: 'CRITICAL', color: AppColors.critical);
      case IncidentPriority.high:
        return const PriorityBadge(
          label: 'HIGH', color: AppColors.high);
      case IncidentPriority.medium:
        return const PriorityBadge(
          label: 'MEDIUM', color: Color(0xFF7ED321));
      case IncidentPriority.low:
        return const PriorityBadge(
          label: 'LOW', color: AppColors.textMuted);
    }
  }

  factory PriorityBadge.live() {
    return const PriorityBadge(
      label: 'LIVE', color: AppColors.live, pulsing: true);
  }

  factory PriorityBadge.fromNotificationType(NotificationType type) {
    switch (type) {
      case NotificationType.live:
        return PriorityBadge.live();
      case NotificationType.critical:
        return const PriorityBadge(
          label: 'CRITICAL', color: AppColors.critical);
      case NotificationType.high:
        return const PriorityBadge(label: 'HIGH', color: AppColors.high);
      default:
        return const PriorityBadge(
          label: 'INFO', color: AppColors.primary);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pulsing) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
