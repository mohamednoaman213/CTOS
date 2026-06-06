import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../shared/widgets/ctos_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';

class VerifyingIdentityScreen extends StatelessWidget {
  final String role;
  const VerifyingIdentityScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is IdentityVerifiedState) {
          context.go(
            '${AppRouter.identityVerified}?role=${state.role}',
          );
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          context.go(
            '${AppRouter.identityVerification}?role=$role',
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CtosLogo(size: 70, showText: false),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2.5,
              ),
              const SizedBox(height: 32),
              const Text(
                'Verifying Identity...',
                style: AppTextStyles.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Contacting secure servers.\nThis will only take a moment.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
