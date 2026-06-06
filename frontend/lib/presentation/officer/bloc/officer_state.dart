import 'package:equatable/equatable.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/unit_model.dart';

class OfficerState extends Equatable {
  final int currentTab;
  final List<IncidentModel> incidents;
  final List<NotificationModel> notifications;
  final List<UnitModel> units;
  final String? alertMessage;
  final String? alertIncidentId;
  final bool isResponding;

  const OfficerState({
    this.currentTab = 0,
    this.incidents = const [],
    this.notifications = const [],
    this.units = const [],
    this.alertMessage,
    this.alertIncidentId,
    this.isResponding = false,
  });

  int get unitsActive => units.where((u) => u.status == UnitStatus.available).length;

  OfficerState copyWith({
    int? currentTab,
    List<IncidentModel>? incidents,
    List<NotificationModel>? notifications,
    List<UnitModel>? units,
    String? alertMessage,
    String? alertIncidentId,
    bool clearAlert = false,
    bool? isResponding,
  }) {
    return OfficerState(
      currentTab: currentTab ?? this.currentTab,
      incidents: incidents ?? this.incidents,
      notifications: notifications ?? this.notifications,
      units: units ?? this.units,
      alertMessage: clearAlert ? null : (alertMessage ?? this.alertMessage),
      alertIncidentId: clearAlert ? null : (alertIncidentId ?? this.alertIncidentId),
      isResponding: isResponding ?? this.isResponding,
    );
  }

  @override
  List<Object?> get props => [
        currentTab, incidents, notifications, units,
        alertMessage, alertIncidentId, isResponding
      ];
}
