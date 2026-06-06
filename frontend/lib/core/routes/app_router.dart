import 'package:go_router/go_router.dart';
import '../../presentation/auth/screens/splash_screen.dart';
import '../../presentation/auth/screens/role_selection_screen.dart';
import '../../presentation/auth/screens/identity_verification_screen.dart';
import '../../presentation/auth/screens/verifying_identity_screen.dart';
import '../../presentation/auth/screens/identity_verified_screen.dart';
import '../../presentation/auth/screens/welcome_screen.dart';
import '../../presentation/citizen/screens/citizen_main_screen.dart';
import '../../presentation/citizen/screens/submit_report_screen.dart';
import '../../presentation/citizen/screens/report_submitted_screen.dart';
import '../../presentation/citizen/screens/citizen_profile_screen.dart';
import '../../presentation/officer/screens/officer_main_screen.dart';
import '../../presentation/officer/screens/officer_profile_screen.dart';
import '../../presentation/auth/screens/login_screen.dart';

class AppRouter {
  static const splash = '/';
  static const roleSelection = '/role-selection';
  static const identityVerification = '/identity-verification';
  static const verifyingIdentity = '/verifying-identity';
  static const identityVerified = '/identity-verified';
  static const welcome = '/welcome';
  static const citizenHome = '/citizen';
  static const submitReport = '/citizen/submit-report';
  static const reportSubmitted = '/citizen/report-submitted';
  static const citizenProfile = '/citizen/profile';
  static const officerHome = '/officer';
  static const officerProfile = '/officer/profile';
  static const login = '/login';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (_, _s) => const SplashScreen()),
      GoRoute(path: roleSelection, builder: (_, _s) => const RoleSelectionScreen()),
      GoRoute(
        path: identityVerification,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'citizen';
          return IdentityVerificationScreen(role: role);
        },
      ),
      GoRoute(
        path: verifyingIdentity,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'citizen';
          return VerifyingIdentityScreen(role: role);
        },
      ),
      GoRoute(
        path: identityVerified,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'citizen';
          return IdentityVerifiedScreen(role: role);
        },
      ),
      GoRoute(
        path: welcome,
        builder: (_, state) {
          final role = state.uri.queryParameters['role'] ?? 'citizen';
          final name = state.uri.queryParameters['name'] ?? 'User';
          return WelcomeScreen(role: role, name: name);
        },
      ),
      GoRoute(path: citizenHome, builder: (_, _s) => const CitizenMainScreen()),
      GoRoute(path: submitReport, builder: (_, _s) => const SubmitReportScreen()),
      GoRoute(path: reportSubmitted, builder: (_, _s) => const ReportSubmittedScreen()),
      GoRoute(path: citizenProfile, builder: (_, _s) => const CitizenProfileScreen()),
      GoRoute(path: officerHome, builder: (_, _s) => const OfficerMainScreen()),
      GoRoute(path: officerProfile, builder: (_, _s) => const OfficerProfileScreen()),
      GoRoute(path: login, builder: (_, _s) => const LoginScreen()),
    ],
  );
}
