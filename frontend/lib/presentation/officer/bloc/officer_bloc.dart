import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/unit_model.dart';
import '../../../data/services/api_client.dart';
import 'officer_event.dart';
import 'officer_state.dart';

class OfficerBloc extends Bloc<OfficerEvent, OfficerState> {
  OfficerBloc() : super(const OfficerState()) {
    on<LoadOfficerDataEvent>(_onLoad);
    on<NavigateToTabEvent>(_onNavigate);
    on<RespondToIncidentEvent>(_onRespond);
    on<ShowAlertEvent>(_onShowAlert);
    on<AssignIncidentEvent>(_onAssign);
    on<UpdateIncidentStatusEvent>(_onUpdateStatus);
  }

  Future<void> _onLoad(
      LoadOfficerDataEvent event, Emitter<OfficerState> emit) async {
    final userId = AppSession.instance.userId;

    try {
      final results = await Future.wait([
        ApiClient.get('/api/event/get-all'),
        ApiClient.get('/api/unit/available'),
        ApiClient.get('/api/notification/user/$userId'),
      ]);

      final eventsResp = results[0];
      final unitsResp = results[1];
      final notifResp = results[2];

      List<IncidentModel> incidents = [];
      if (eventsResp.statusCode == 200) {
        final list = jsonDecode(eventsResp.body) as List;
        incidents = list
            .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      List<UnitModel> units = [];
      if (unitsResp.statusCode == 200) {
        final list = jsonDecode(unitsResp.body) as List;
        units = list
            .map((u) => UnitModel.fromJson(u as Map<String, dynamic>))
            .toList();
      }

      List<NotificationModel> notifications = [];
      if (notifResp.statusCode == 200) {
        final list = jsonDecode(notifResp.body) as List;
        notifications = list
            .map((n) => NotificationModel.fromJson(n as Map<String, dynamic>))
            .toList();
      }

      emit(state.copyWith(
        incidents: incidents,
        units: units,
        notifications: notifications,
      ));
    } catch (_) {
      // keep previous state on error
    }
  }

  void _onNavigate(NavigateToTabEvent event, Emitter<OfficerState> emit) {
    emit(state.copyWith(currentTab: event.index));
    if (event.index == 1) add(LoadOfficerDataEvent());
  }

  void _onRespond(RespondToIncidentEvent event, Emitter<OfficerState> emit) {
    emit(state.copyWith(isResponding: true, clearAlert: true));
  }

  void _onShowAlert(ShowAlertEvent event, Emitter<OfficerState> emit) {
    emit(state.copyWith(
      alertMessage: event.message,
      alertIncidentId: event.incidentId,
    ));
  }

  void _onAssign(AssignIncidentEvent event, Emitter<OfficerState> emit) {
    final updated =
        state.incidents.where((r) => r.id != event.incidentId).toList();
    emit(state.copyWith(incidents: updated));
  }

  Future<void> _onUpdateStatus(
      UpdateIncidentStatusEvent event, Emitter<OfficerState> emit) async {
    try {
      final response = await ApiClient.patch(
        '/api/event/${event.dbId}/status',
        '{"status":"${event.newStatus}"}',
      );
      if (response.statusCode == 200) {
        final statusEnum = _toEnum(event.newStatus);
        final updated = state.incidents.map((r) {
          return r.dbId == event.dbId ? r.copyWithStatus(statusEnum) : r;
        }).toList();
        emit(state.copyWith(incidents: updated));
      }
    } catch (_) {}
  }

  static IncidentStatus _toEnum(String status) {
    switch (status) {
      case 'NotResolved': return IncidentStatus.ongoing;
      case 'Resolved': return IncidentStatus.resolved;
      default: return IncidentStatus.pending;
    }
  }
}
