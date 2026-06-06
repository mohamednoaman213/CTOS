import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../shared/widgets/ctos_logo.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? _selectedRole;
  bool _showError = false;

  void _onVerify() {
    if (_selectedRole == null) {
      setState(() => _showError = true);
      return;
    }
    context.go(
      '${AppRouter.identityVerification}?role=$_selectedRole',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const CtosLogo(size: 64),
              const SizedBox(height: 8),
              Text(
                'Citizen Incident Reporting',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  letterSpacing: 3,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Identify Your Role',
                style: AppTextStyles.headlineLarge.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 8),
              Text(
                'Select user type to initialize secure\nreporting protocol',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 36),
              Row(
                children: [
                  Expanded(
                    child: _RoleCard(
                      title: 'Citizen',
                      subtitle: 'Report incidents\nanonymously',
                      icon: Icons.person_outline,
                      isSelected: _selectedRole == 'citizen',
                      onTap: () => setState(() {
                        _selectedRole = 'citizen';
                        _showError = false;
                      }),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _RoleCard(
                      title: 'Official',
                      subtitle: 'Manage and\nvalidate reports',
                      icon: Icons.local_police_outlined,
                      isSelected: _selectedRole == 'officer',
                      onTap: () => setState(() {
                        _selectedRole = 'officer';
                        _showError = false;
                      }),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (_showError) ...[
                Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: AppColors.critical, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Please select a role to continue',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.critical,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              ElevatedButton.icon(
                onPressed: _onVerify,
                icon: const Icon(Icons.fingerprint, size: 22),
                label: const Text('Verify Identity'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.headlineSmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
}
