import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/services/api_client.dart';
import 'citizen_event.dart';
import 'citizen_state.dart';

class CitizenBloc extends Bloc<CitizenEvent, CitizenState> {
  CitizenBloc() : super(const CitizenState()) {
    on<LoadCitizenDataEvent>(_onLoad);
    on<NavigateToTabEvent>(_onNavigate);
    on<ShowAlertEvent>(_onShowAlert);
    on<DismissAlertEvent>(_onDismissAlert);
  }

  Future<void> _onLoad(
      LoadCitizenDataEvent event, Emitter<CitizenState> emit) async {
    emit(state.copyWith(isLoading: true));
    final userId = AppSession.instance.userId;

    try {
      final results = await Future.wait([
        ApiClient.get('/api/event/get-all'),
        ApiClient.get('/api/notification/user/$userId'),
      ]);

      final eventsResp = results[0];
      final notifResp = results[1];

      List<IncidentModel> reports = [];
      if (eventsResp.statusCode == 200) {
        final list = jsonDecode(eventsResp.body) as List;
        reports = list
            .map((e) => IncidentModel.fromJson(e as Map<String, dynamic>))
            .where((e) => e.userId == userId)
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
        reports: reports,
        notifications: notifications,
        isLoading: false,
      ));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  void _onNavigate(NavigateToTabEvent event, Emitter<CitizenState> emit) {
    emit(state.copyWith(currentTab: event.index));
  }

  void _onShowAlert(ShowAlertEvent event, Emitter<CitizenState> emit) {
    emit(state.copyWith(alertMessage: event.message));
  }

  void _onDismissAlert(DismissAlertEvent event, Emitter<CitizenState> emit) {
    emit(state.copyWith(clearAlert: true));
  }
}
