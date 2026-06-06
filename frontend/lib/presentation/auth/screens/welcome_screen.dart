import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/session/app_session.dart';
import '../../shared/widgets/ctos_logo.dart';

class WelcomeScreen extends StatefulWidget {
  final String role;
  final String name;
  const WelcomeScreen({super.key, required this.role, required this.name});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward().then((_) async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          final dest = widget.role == 'officer'
              ? AppRouter.officerHome
              : AppRouter.citizenHome;
          context.go(dest);
        }
      });
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionName = AppSession.instance.name.isNotEmpty
        ? AppSession.instance.name.toUpperCase()
        : widget.name.toUpperCase();
    final welcomeText = 'WELCOME TO CTOS, $sessionName!';

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: FadeTransition(
          opacity: _fade,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CtosLogo(size: 80),
              const SizedBox(height: 48),
              Text(
                welcomeText,
                textAlign: TextAlign.center,
                style: AppTextStyles.primaryAccentLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
