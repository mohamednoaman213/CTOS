import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/user_model.dart';

class OfficerProfileScreen extends StatelessWidget {
  const OfficerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserModel.fromSession();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go(AppRouter.officerHome),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: AppColors.textSecondary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      AppSession.instance.clear();
                      context.go(AppRouter.roleSelection);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.critical.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.critical.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.logout,
                              color: AppColors.critical, size: 16),
                          SizedBox(width: 4),
                          Text('LOG OUT',
                              style: TextStyle(
                                  color: AppColors.critical,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundColor: AppColors.surface,
                    child: Icon(Icons.local_police,
                        color: AppColors.textSecondary, size: 48),
                  ),
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: AppColors.onlineGreen,
                      shape: BoxShape.circle,
                      border:
                          Border.all(color: AppColors.background, width: 2),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(user.name, style: AppTextStyles.headlineMedium),
              const SizedBox(height: 4),
              Text(user.title,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.primary)),
              const SizedBox(height: 4),
              Text('ID: ${user.id}',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatBox(
                      value: '${user.reportCount}',
                      label: 'REPORTS',
                      icon: Icons.assignment_outlined),
                  const SizedBox(width: 10),
                  _StatBox(
                      value: user.reportCount > 0
                          ? '${user.aiScore.toStringAsFixed(0)}%'
                          : 'N/A',
                      label: 'RATING',
                      icon: Icons.star_outline),
                  const SizedBox(width: 10),
                  _StatBox(
                      value: user.impactGrade,
                      label: 'IMPACT',
                      icon: Icons.people_outline),
                ],
              ),
              const SizedBox(height: 20),
              _InfoTile(
                icon: Icons.email_outlined,
                title: 'Email',
                subtitle: AppSession.instance.email.isNotEmpty
                    ? AppSession.instance.email
                    : 'Not set',
                trailing: const Icon(Icons.edit_outlined,
                    color: AppColors.primary, size: 16),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.badge_outlined,
                title: 'Officer ID',
                subtitle: 'VERIFIED',
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.map_outlined,
                title: 'Map Proximity',
                subtitle: 'Up to 2.5 km radius',
                badge: 'HIGH',
                trailing: const Icon(Icons.chevron_right,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 10),
              _InfoTile(
                icon: Icons.people_outline,
                title: 'Backup Network',
                subtitle: '3 Active Backup Units',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    3,
                    (i) => Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.background, width: 1),
                      ),
                      child: const Icon(Icons.local_police,
                          color: AppColors.textMuted, size: 12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBox(
      {required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(value,
                style: AppTextStyles.headlineMedium
                    .copyWith(color: AppColors.primary)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    AppTextStyles.labelMedium.copyWith(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final String? badge;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: AppTextStyles.titleMedium),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.high.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge!,
                            style: const TextStyle(
                                color: AppColors.high,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                    const Spacer(),
                    trailing,
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
