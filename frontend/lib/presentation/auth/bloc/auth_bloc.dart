import 'dart:convert';
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../core/session/app_session.dart';
import 'package:http/http.dart' as http;

const _baseUrl = 'http://ctos-api.runasp.net';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<SelectRoleEvent>(_onSelectRole);
    on<StartVerificationEvent>(_onStartVerification);
    on<LoginEvent>(_onLogin);
    on<VerificationCompleteEvent>(_onVerificationComplete);
    on<LogoutEvent>(_onLogout);
  }

  void _onSelectRole(SelectRoleEvent event, Emitter<AuthState> emit) {
    emit(RoleSelectedState(event.role));
  }

  Future<void> _onStartVerification(
    StartVerificationEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingIdentityState(role: event.role, name: event.name));

    try {
      final body = jsonEncode({
        'userId': _generateUserId(),
        'fullName': event.name,
        'email': event.email,
        'passwordHash': event.password,
        'nationalId': event.nationalId,
        'userType': event.role == 'officer' ? 'Official' : 'Citizen',
        'nationalIdFrontImageUrl': event.idFrontBase64 ?? '',
        'nationalIdBackImageUrl': event.idBackBase64 ?? '',
        // TODO: swap image fields for a proper file-upload endpoint in production
      });

      final endpoint = event.role == 'officer'
          ? '$_baseUrl/api/User/Register/Official'
          : '$_baseUrl/api/User/Register/Citizen';

      final response = await _postWithRetry(endpoint, body);
      print('REGISTER STATUS: ${response.statusCode}');
      print('REGISTER BODY: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userId = (data['id'] as num?)?.toInt() ?? 0;

        AppSession.instance.name = event.name;
        AppSession.instance.email = event.email;
        AppSession.instance.role = event.role;
        AppSession.instance.userId = userId;

        emit(IdentityVerifiedState(role: event.role, name: event.name));
        await Future.delayed(const Duration(seconds: 1));
        emit(AuthenticatedState(role: event.role, name: event.name, userId: userId));
      } else {
        emit(AuthErrorState('Registration failed (${response.statusCode}). Please try again.'));
      }
    } catch (e) {
      print('REGISTER ERROR: $e');
      emit(AuthErrorState('Error: $e'));
    }
  }

  Future<void> _onLogin(
    LoginEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(VerifyingIdentityState(role: '', name: ''));

    try {
      final body = jsonEncode({
        'email': event.email,
        'passwordHash': event.password,
      });

      final response = await _postWithRetry('$_baseUrl/api/User/Login', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final userId = (data['id'] as num?)?.toInt() ?? 0;
        final name = (data['fullName'] as String?) ?? '';
        final userType = (data['userType'] as String?) ?? 'Citizen';
        final role = userType.toLowerCase() == 'official' ? 'officer' : 'citizen';

        AppSession.instance.name = name;
        AppSession.instance.email = event.email;
        AppSession.instance.role = role;
        AppSession.instance.userId = userId;

        emit(AuthenticatedState(role: role, name: name, userId: userId));
      } else {
        emit(AuthErrorState('Invalid email or password.'));
      }
    } catch (e) {
      emit(AuthErrorState('Connection error. Check your internet and try again.'));
    }
  }

  void _onVerificationComplete(
    VerificationCompleteEvent event,
    Emitter<AuthState> emit,
  ) {
    if (state is IdentityVerifiedState) {
      final s = state as IdentityVerifiedState;
      emit(AuthenticatedState(role: s.role, name: s.name));
    }
  }

  void _onLogout(LogoutEvent event, Emitter<AuthState> emit) {
    AppSession.instance.clear();
    emit(AuthInitial());
  }

  String _generateUserId() {
    final rng = Random.secure();
    String hex(int bytes) => List.generate(bytes, (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
    return '${hex(4)}-${hex(2)}-${hex(2)}-${hex(2)}-${hex(6)}';
  }

  Future<http.Response> _postWithRetry(String url, String body,
      {int retries = 3}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await http
            .post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: body,
            )
            .timeout(const Duration(seconds: 30));
        return response;
      } catch (e) {
        print('Attempt $attempt failed: $e');
        if (attempt == retries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('All retries failed');
  }
}
