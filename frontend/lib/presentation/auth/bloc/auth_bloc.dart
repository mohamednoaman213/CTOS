import 'dart:convert';
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
      final endpoint = event.role == 'officer'
          ? '$_baseUrl/api/User/Register/Official'
          : '$_baseUrl/api/User/Register/Citizen';

      final request = http.MultipartRequest('POST', Uri.parse(endpoint))
        ..fields['FullName'] = event.name
        ..fields['Email'] = event.email
        ..fields['PasswordHash'] = event.password
        ..fields['NationalId'] = event.nationalId;

      if (event.idFrontPath != null) {
        request.files.add(
            await http.MultipartFile.fromPath('FrontId', event.idFrontPath!));
      }
      if (event.idBackPath != null) {
        request.files.add(
            await http.MultipartFile.fromPath('BackId', event.idBackPath!));
      }

      final streamed = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamed);

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
      emit(AuthErrorState('Connection error. Check your internet and try again.'));
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
        if (attempt == retries) rethrow;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    throw Exception('All retries failed');
  }
}
