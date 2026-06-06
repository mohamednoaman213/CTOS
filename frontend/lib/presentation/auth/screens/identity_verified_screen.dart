import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../shared/widgets/ctos_logo.dart';

class IdentityVerifiedScreen extends StatefulWidget {
  final String role;
  const IdentityVerifiedScreen({super.key, required this.role});

  @override
  State<IdentityVerifiedScreen> createState() => _IdentityVerifiedScreenState();
}

class _IdentityVerifiedScreenState extends State<IdentityVerifiedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward().then((_) async {
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('${AppRouter.welcome}?role=${widget.role}&name=Karim');
        }
      });
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CtosLogo(size: 80),
            const SizedBox(height: 48),
            ScaleTransition(
              scale: _scale,
              child: Text(
                'Identity Verified\nSuccessfully!',
                textAlign: TextAlign.center,
                style: AppTextStyles.primaryAccentLarge.copyWith(fontSize: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
