import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class RoleSelectedState extends AuthState {
  final String role;
  const RoleSelectedState(this.role);
  @override
  List<Object?> get props => [role];
}

class VerifyingIdentityState extends AuthState {
  final String role;
  final String name;
  const VerifyingIdentityState({required this.role, required this.name});
  @override
  List<Object?> get props => [role, name];
}

class IdentityVerifiedState extends AuthState {
  final String role;
  final String name;
  const IdentityVerifiedState({required this.role, required this.name});
  @override
  List<Object?> get props => [role, name];
}

class AuthenticatedState extends AuthState {
  final String role;
  final String name;
  final int userId;
  const AuthenticatedState({required this.role, required this.name, this.userId = 0});
  @override
  List<Object?> get props => [role, name, userId];
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}
