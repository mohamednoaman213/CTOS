import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_router.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/search_bar_widget.dart';
import '../bloc/officer_bloc.dart';
import '../bloc/officer_event.dart';
import '../bloc/officer_state.dart';
import 'officer_map_screen.dart';
import 'officer_dashboard_screen.dart';
import 'units_screen.dart';
import 'officer_notifications_screen.dart';

class OfficerMainScreen extends StatelessWidget {
  const OfficerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OfficerBloc()..add(LoadOfficerDataEvent()),
      child: const _OfficerMainView(),
    );
  }
}

class _OfficerMainView extends StatelessWidget {
  const _OfficerMainView();

  static const _tabs = [
    OfficerMapScreen(),
    OfficerDashboardScreen(),
    UnitsScreen(),
    OfficerNotificationsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfficerBloc, OfficerState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppHeader(
                user: UserModel.fromSession(),
                onSettingsTap: () => context.go(AppRouter.officerProfile),
              ),
              if (state.currentTab == 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: SearchBarWidget(),
                ),
              Expanded(child: _tabs[state.currentTab]),
            ],
          ),
          bottomNavigationBar:
              _OfficerBottomNav(currentTab: state.currentTab),
        );
      },
    );
  }
}

class _OfficerBottomNav extends StatelessWidget {
  final int currentTab;
  const _OfficerBottomNav({required this.currentTab});

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
                    .read<OfficerBloc>()
                    .add(const NavigateToTabEvent(0)),
              ),
              _NavItem(
                icon: Icons.dashboard_outlined,
                label: 'Dashboard',
                isSelected: currentTab == 1,
                onTap: () => context
                    .read<OfficerBloc>()
                    .add(const NavigateToTabEvent(1)),
              ),
              _NavItem(
                icon: Icons.local_police_outlined,
                label: 'Units',
                isSelected: currentTab == 2,
                onTap: () => context
                    .read<OfficerBloc>()
                    .add(const NavigateToTabEvent(2)),
              ),
              _NavItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                isSelected: currentTab == 3,
                showBadge: true,
                onTap: () => context
                    .read<OfficerBloc>()
                    .add(const NavigateToTabEvent(3)),
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
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
