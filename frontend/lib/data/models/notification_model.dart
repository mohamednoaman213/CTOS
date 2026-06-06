import 'package:equatable/equatable.dart';
import 'incident_model.dart';

enum NotificationType { live, critical, high, info, friend }

class NotificationModel extends Equatable {
  final String id;
  final String message;
  final NotificationType type;
  final String? incidentId;
  final String timeAgo;
  final bool isRead;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.type,
    this.incidentId,
    required this.timeAgo,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    return NotificationModel(
      id: json['id'].toString(),
      message: json['body'] as String? ?? '',
      type: _parseType(title),
      incidentId: json['eventId']?.toString(),
      timeAgo: _toTimeAgo(json['createdAt'] as String?),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  static NotificationType _parseType(String title) {
    final t = title.toLowerCase();
    if (t.contains('critical') || t.contains('emergency')) return NotificationType.critical;
    if (t.contains('high') || t.contains('backup') || t.contains('report')) return NotificationType.high;
    if (t.contains('live')) return NotificationType.live;
    if (t.contains('friend')) return NotificationType.friend;
    return NotificationType.info;
  }

  static String _toTimeAgo(String? iso) {
    if (iso == null) return 'Unknown';
    try {
      final dt = DateTime.parse(iso).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} hr ago';
      return '${diff.inDays} days ago';
    } catch (_) {
      return 'Unknown';
    }
  }

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
