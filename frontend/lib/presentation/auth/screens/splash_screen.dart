import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/services/app_init_service.dart';
import '../../shared/widgets/ctos_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    // Navigate only when BOTH the animation has finished AND all real
    // system initialization has completed — whichever takes longer wins.
    Future.wait([
      _controller.forward().orCancel,
      AppInitService.instance.initFuture,
    ]).then((_) async {
      // Brief pause so the tagline is readable before transitioning
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) context.go(AppRouter.roleSelection);
    }).catchError((_) {
      // Animation was cancelled (widget disposed) — navigate anyway
      if (mounted) context.go(AppRouter.roleSelection);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CtosLogo(size: 88),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _taglineFade,
                child: const Text(
                  'Empowering citizens.\nEnhancing safety.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.tagline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
