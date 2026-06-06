import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/unit_model.dart';
import 'officer_event.dart';
import 'officer_state.dart';

class OfficerBloc extends Bloc<OfficerEvent, OfficerState> {
  OfficerBloc() : super(const OfficerState()) {
    on<LoadOfficerDataEvent>(_onLoad);
    on<NavigateToTabEvent>(_onNavigate);
    on<RespondToIncidentEvent>(_onRespond);
    on<ShowAlertEvent>(_onShowAlert);
    on<AssignIncidentEvent>(_onAssign);
  }

  void _onLoad(LoadOfficerDataEvent event, Emitter<OfficerState> emit) {
    final queue = List.of(AppSession.instance.officerQueue);
    emit(state.copyWith(
      incidents: queue,
      notifications: const [],
      units: UnitModel.mockList,
    ));
  }

  void _onNavigate(NavigateToTabEvent event, Emitter<OfficerState> emit) {
    emit(state.copyWith(currentTab: event.index));
    // Refresh report list whenever the officer opens the Dashboard tab
    if (event.index == 1) {
      add(LoadOfficerDataEvent());
    }
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
    AppSession.instance.officerQueue.removeWhere((r) => r.id == event.incidentId);
    final updated = state.incidents.where((r) => r.id != event.incidentId).toList();
    emit(state.copyWith(incidents: updated));
  }
}
