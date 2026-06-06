import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../shared/widgets/ctos_logo.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email and password.')),
      );
      return;
    }

    context.read<AuthBloc>().add(LoginEvent(email: email, password: password));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          final dest = state.role == 'officer'
              ? AppRouter.officerHome
              : AppRouter.citizenHome;
          context.go(dest);
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => context.go(
                      '${AppRouter.identityVerification}?role=citizen'),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                Center(child: const CtosLogo(size: 60, showText: false)),
                const SizedBox(height: 16),
                const Center(
                  child: Text('Welcome Back', style: AppTextStyles.headlineLarge),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Log in to your CTOS account',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: 40),
                _FieldLabel('Email Address'),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'name@domain.com',
                    suffixIcon: Icon(Icons.mail_outline,
                        color: AppColors.textMuted, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                _FieldLabel('Password'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  style: const TextStyle(color: AppColors.textPrimary),
                  onSubmitted: (_) => _onLogin(),
                  decoration: InputDecoration(
                    hintText: 'Enter your password',
                    suffixIcon: GestureDetector(
                      onTap: () =>
                          setState(() => _passwordVisible = !_passwordVisible),
                      child: Icon(
                        _passwordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                        size: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final isLoading = state is VerifyingIdentityState;
                    return ElevatedButton(
                      onPressed: isLoading ? null : _onLogin,
                      child: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.background,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text('Log In'),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward, size: 18),
                              ],
                            ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_outline,
                        color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '256-bit SSL Encryption',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Center(
                  child: GestureDetector(
                    onTap: () => context.go(
                        '${AppRouter.identityVerification}?role=citizen'),
                    child: Text(
                      "Don't have an account? Register",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600));
  }
}
