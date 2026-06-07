import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/search_bar_widget.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_event.dart';
import '../bloc/citizen_state.dart';
import 'citizen_map_screen.dart';
import 'my_reports_screen.dart';
import 'citizen_notifications_screen.dart';

class CitizenMainScreen extends StatelessWidget {
  const CitizenMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CitizenBloc()..add(LoadCitizenDataEvent()),
      child: const _CitizenMainView(),
    );
  }
}

class _CitizenMainView extends StatelessWidget {
  const _CitizenMainView();

  static const _tabs = [
    CitizenMapScreen(),
    MyReportsScreen(),
    CitizenNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CitizenBloc, CitizenState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppHeader(
                user: UserModel.fromSession(),
                onSettingsTap: () => context.go(AppRouter.citizenProfile),
              ),
              if (state.currentTab == 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SearchBarWidget(),
                ),
              Expanded(child: _tabs[state.currentTab]),
            ],
          ),
          floatingActionButton: state.currentTab == 0
              ? FloatingActionButton(
                  onPressed: () => context.go(AppRouter.submitReport),
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.add,
                      color: AppColors.background, size: 28),
                )
              : null,
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          bottomNavigationBar: _CitizenBottomNav(currentTab: state.currentTab),
        );
      },
    );
  }
}

class _CitizenBottomNav extends StatelessWidget {
  final int currentTab;
  const _CitizenBottomNav({required this.currentTab});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: AppColors.divider, width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 58,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.map_outlined,
                label: 'Map',
                isSelected: currentTab == 0,
                onTap: () => context
                    .read<CitizenBloc>()
                    .add(const NavigateToTabEvent(0)),
              ),
              _NavItem(
                icon: Icons.assignment_outlined,
                label: 'Reports',
                isSelected: currentTab == 1,
                onTap: () => context
                    .read<CitizenBloc>()
                    .add(const NavigateToTabEvent(1)),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                isSelected: currentTab == 2,
                showBadge: true,
                onTap: () => context
                    .read<CitizenBloc>()
                    .add(const NavigateToTabEvent(2)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final bool showBadge;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 22),
                if (showBadge)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.critical,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
