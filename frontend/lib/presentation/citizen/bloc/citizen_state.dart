import 'package:equatable/equatable.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/friend_model.dart';

class CitizenState extends Equatable {
  final int currentTab;
  final List<IncidentModel> reports;
  final List<NotificationModel> notifications;
  final List<FriendModel> friendRequests;
  final List<FriendModel> friendActivity;
  final String? alertMessage;
  final bool isLoading;

  const CitizenState({
    this.currentTab = 0,
    this.reports = const [],
    this.notifications = const [],
    this.friendRequests = const [],
    this.friendActivity = const [],
    this.alertMessage,
    this.isLoading = false,
  });

  CitizenState copyWith({
    int? currentTab,
    List<IncidentModel>? reports,
    List<NotificationModel>? notifications,
    List<FriendModel>? friendRequests,
    List<FriendModel>? friendActivity,
    String? alertMessage,
    bool clearAlert = false,
    bool? isLoading,
  }) {
    return CitizenState(
      currentTab: currentTab ?? this.currentTab,
      reports: reports ?? this.reports,
      notifications: notifications ?? this.notifications,
      friendRequests: friendRequests ?? this.friendRequests,
      friendActivity: friendActivity ?? this.friendActivity,
      alertMessage: clearAlert ? null : (alertMessage ?? this.alertMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        currentTab, reports, notifications,
        friendRequests, friendActivity, alertMessage, isLoading
      ];
}
