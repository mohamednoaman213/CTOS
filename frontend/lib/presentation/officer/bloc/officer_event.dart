import 'package:equatable/equatable.dart';

abstract class OfficerEvent extends Equatable {
  const OfficerEvent();
  @override
  List<Object?> get props => [];
}

class LoadOfficerDataEvent extends OfficerEvent {}

class NavigateToTabEvent extends OfficerEvent {
  final int index;
  const NavigateToTabEvent(this.index);
  @override
  List<Object?> get props => [index];
}

class RespondToIncidentEvent extends OfficerEvent {
  final String incidentId;
  const RespondToIncidentEvent(this.incidentId);
  @override
  List<Object?> get props => [incidentId];
}

class ShowAlertEvent extends OfficerEvent {
  final String message;
  final String incidentId;
  const ShowAlertEvent({required this.message, required this.incidentId});
}

class AssignIncidentEvent extends OfficerEvent {
  final String incidentId;
  const AssignIncidentEvent(this.incidentId);
  @override
  List<Object?> get props => [incidentId];
}
