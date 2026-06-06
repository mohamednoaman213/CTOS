import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../shared/widgets/app_header.dart';
import '../../../data/models/user_model.dart';

class ReportSubmittedScreen extends StatefulWidget {
  const ReportSubmittedScreen({super.key});

  @override
  State<ReportSubmittedScreen> createState() => _ReportSubmittedScreenState();
}

class _ReportSubmittedScreenState extends State<ReportSubmittedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward().then((_) async {
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) setState(() => _showDetails = true);
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(user: UserModel.fromSession(), onSettingsTap: () {}),
          Expanded(
            child: Center(
              child: FadeTransition(
                opacity: _fade,
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Report Submitted Successfully',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.headlineMedium,
                      ),
                      if (_showDetails) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Officers will be en route soon',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => context.go(AppRouter.citizenHome),
                          child: Text(
                            'You can check report progress\nthrough my reports tab',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () => context.go(AppRouter.citizenHome),
                          child: const Text('Back to Map'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
