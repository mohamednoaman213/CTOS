import 'package:equatable/equatable.dart';

abstract class CitizenEvent extends Equatable {
  const CitizenEvent();
  @override
  List<Object?> get props => [];
}

class LoadCitizenDataEvent extends CitizenEvent {}

class NavigateToTabEvent extends CitizenEvent {
  final int index;
  const NavigateToTabEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class ShowAlertEvent extends CitizenEvent {
  final String message;
  const ShowAlertEvent(this.message);
}

class DismissAlertEvent extends CitizenEvent {}
