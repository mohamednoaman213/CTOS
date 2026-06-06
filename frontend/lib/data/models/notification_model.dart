import 'package:equatable/equatable.dart';
import 'incident_model.dart';

enum NotificationType { live, critical, high, info, friend }

class NotificationModel extends Equatable {
  final String id;
  final String message;
  final NotificationType type;
  final String? incidentId;
  final String timeAgo;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    this.incidentId,
    required this.timeAgo,
  });

  IncidentPriority get priority {
    switch (type) {
      case NotificationType.critical:
        return IncidentPriority.critical;
      case NotificationType.high:
        return IncidentPriority.high;
      case NotificationType.live:
        return IncidentPriority.critical;
      default:
        return IncidentPriority.low;
    }
  }

  static final citizenNotifications = [
    const NotificationModel(
      id: '1',
      message: 'Multiple fire reports near home',
      type: NotificationType.live,
      timeAgo: '2 min ago',
    ),
    const NotificationModel(
      id: '2',
      message: 'An officer responded to your latest report',
      type: NotificationType.critical,
      timeAgo: '15 min ago',
    ),
    const NotificationModel(
      id: '3',
      message: 'Your friend reported a car collision on 45th Street',
      type: NotificationType.high,
      timeAgo: '1 hr ago',
    ),
    const NotificationModel(
      id: '4',
      message: 'AYA SAMEH sent you a friend request',
      type: NotificationType.info,
      timeAgo: '2 hr ago',
    ),
  ];

  static final officerNotifications = [
    const NotificationModel(
      id: '1',
      message: 'Unit 14 just requested backup in Abu Qir',
      type: NotificationType.critical,
      incidentId: '93T2R0',
      timeAgo: '1 min ago',
    ),
    const NotificationModel(
      id: '2',
      message: 'Fire reported 4km away',
      type: NotificationType.critical,
      incidentId: '832P2N',
      timeAgo: '5 min ago',
    ),
    const NotificationModel(
      id: '3',
      message: '4 Reports on queue',
      type: NotificationType.high,
      incidentId: '28Y2T2',
      timeAgo: '10 min ago',
    ),
    const NotificationModel(
      id: '4',
      message: 'Officer Hatem just got promoted!',
      type: NotificationType.info,
      timeAgo: '30 min ago',
    ),
  ];

  @override
  List<Object?> get props => [id];
}
