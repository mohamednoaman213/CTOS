import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class SelectRoleEvent extends AuthEvent {
  final String role;
  const SelectRoleEvent(this.role);
  @override
  List<Object?> get props => [role];
}

class StartVerificationEvent extends AuthEvent {
  final String role;
  final String name;
  final String email;
  final String password;
  final String nationalId;
  final String? idFrontBase64;
  final String? idBackBase64;
  const StartVerificationEvent({
    required this.role,
    required this.name,
    required this.email,
    required this.password,
    required this.nationalId,
    this.idFrontBase64,
    this.idBackBase64,
  });
  @override
  List<Object?> get props => [role, name, email, password, nationalId, idFrontBase64, idBackBase64];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;
  const LoginEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class VerificationCompleteEvent extends AuthEvent {}

class LogoutEvent extends AuthEvent {}
