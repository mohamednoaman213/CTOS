import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/session/app_session.dart';
import 'citizen_event.dart';
import 'citizen_state.dart';

class CitizenBloc extends Bloc<CitizenEvent, CitizenState> {
  CitizenBloc() : super(const CitizenState()) {
    on<LoadCitizenDataEvent>(_onLoad);
    on<NavigateToTabEvent>(_onNavigate);
    on<ShowAlertEvent>(_onShowAlert);
    on<DismissAlertEvent>(_onDismissAlert);
  }

  void _onLoad(LoadCitizenDataEvent event, Emitter<CitizenState> emit) {
    final session = AppSession.instance;
    emit(state.copyWith(
      reports: List.from(session.myReports),
      notifications: List.from(session.myNotifications),
      friendRequests: List.from(session.myFriendRequests),
      friendActivity: List.from(session.myFriends),
    ));
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
