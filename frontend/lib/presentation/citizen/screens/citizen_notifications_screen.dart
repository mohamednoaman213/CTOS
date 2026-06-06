import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/notification_model.dart';
import '../../shared/widgets/priority_badge.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_state.dart';

class CitizenNotificationsScreen extends StatelessWidget {
  const CitizenNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CitizenBloc, CitizenState>(
      builder: (context, state) {
        final notifications = state.notifications;
        if (notifications.isEmpty) {
          return const Center(
            child: Text('No notifications', style: AppTextStyles.bodyMedium),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: notifications.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) =>
              _NotificationCard(notification: notifications[i]),
        );
      },
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  const _NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    switch (notification.type) {
      case NotificationType.live:
        borderColor = AppColors.critical;
        break;
      case NotificationType.critical:
        borderColor = AppColors.critical;
        break;
      case NotificationType.high:
        borderColor = AppColors.high;
        break;
      default:
        borderColor = AppColors.medium;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: borderColor, width: 3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              notification.message,
              style: AppTextStyles.titleMedium,
            ),
          ),
          const SizedBox(width: 10),
          PriorityBadge.fromNotificationType(notification.type),
        ],
      ),
    );
  }
}
