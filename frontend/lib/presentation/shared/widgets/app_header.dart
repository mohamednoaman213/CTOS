import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/user_model.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final UserModel user;
  final VoidCallback? onSettingsTap;

  const AppHeader({super.key, required this.user, this.onSettingsTap});

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 16,
        right: 16,
        bottom: 8,
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surface,
                child: Icon(
                  user.role == UserRole.officer
                      ? Icons.local_police
                      : Icons.person,
                  color: AppColors.textSecondary,
                  size: 24,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: user.isOnline
                        ? AppColors.onlineGreen
                        : AppColors.offlineGray,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user.name,
                  style: AppTextStyles.titleLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user.title,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
