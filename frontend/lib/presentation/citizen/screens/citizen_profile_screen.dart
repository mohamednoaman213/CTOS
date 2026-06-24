import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/user_model.dart';

class CitizenProfileScreen extends StatefulWidget {
  const CitizenProfileScreen({super.key});

  @override
  State<CitizenProfileScreen> createState() => _CitizenProfileScreenState();
}

class _CitizenProfileScreenState extends State<CitizenProfileScreen> {
  late bool _notificationsEnabled;

  @override
  void initState() {
    super.initState();
    _notificationsEnabled = AppSession.instance.notificationsEnabled;
  }

  @override
  Widget build(BuildContext context) {
    final user = UserModel.fromSession();
    final reportCount = AppSession.instance.reportCount;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.28, 0.55, 1.0],
            colors: [
              Color(0xFF071520),
              Color(0xFF0A2535),
              Color(0xFF0D1B25),
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Top bar ──────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.go(AppRouter.citizenHome),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.white, size: 16),
                        ),
                      ),
                      const Spacer(),
                      const Text('PROFILE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2)),
                      const Spacer(),
                      const SizedBox(width: 36),
                    ],
                  ),
                ),
              ),

              // ── Avatar + name ─────────────────────────
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.primary, width: 2.5),
                            color: AppColors.surface,
                          ),
                          child: const Icon(Icons.person,
                              color: AppColors.textSecondary, size: 52),
                        ),
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppColors.onlineGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: AppColors.background, width: 2.5),
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 13),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(user.name,
                        style: AppTextStyles.headlineMedium.copyWith(
                            color: Colors.white, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Text(user.title,
                          style: const TextStyle(
                              color: AppColors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 6),
                    Text('ID: ${user.id}',
                        style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 11)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // ── Stats ─────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      _StatCard(
                        value: '$reportCount',
                        label: 'REPORTS',
                        icon: Icons.assignment_outlined,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: reportCount > 0
                            ? '${user.aiScore.toStringAsFixed(0)}%'
                            : 'N/A',
                        label: 'AI-SCORE',
                        icon: Icons.smart_toy_outlined,
                        color: AppColors.medium,
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        value: user.impactGrade,
                        label: 'IMPACT',
                        icon: Icons.trending_up,
                        color: AppColors.high,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Personal Info section ─────────────────
              _sectionHeader('PERSONAL INFO'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(tiles: [
                    _SettingsTile(
                      icon: Icons.email_outlined,
                      title: 'Email',
                      subtitle: AppSession.instance.email.isNotEmpty
                          ? AppSession.instance.email
                          : 'Not set',
                    ),
                    _SettingsTile(
                      icon: Icons.home_outlined,
                      title: 'Home Address',
                      subtitle: 'Home address verified',
                      statusChip: const _StatusChip(
                          label: 'VERIFIED',
                          color: AppColors.onlineGreen),
                    ),
                    _SettingsTile(
                      icon: Icons.badge_outlined,
                      title: 'Citizen ID',
                      subtitle: 'National ID verified',
                      statusChip: const _StatusChip(
                          label: 'VERIFIED',
                          color: AppColors.onlineGreen),
                    ),
                  ]),
                ),
              ),

              // ── AI & Security section ─────────────────
              _sectionHeader('AI & SECURITY'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(tiles: [
                    _SettingsTile(
                      icon: Icons.psychology_outlined,
                      title: 'AI Sensitivity',
                      subtitle: 'Analysis LVL.${user.level}',
                      badge: reportCount > 5 ? 'HIGH' : 'NORMAL',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                    ),
                  ]),
                ),
              ),

              // ── Network section ───────────────────────
              _sectionHeader('NETWORK'),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _SettingsGroup(tiles: [
                    _SettingsTile(
                      icon: Icons.people_outline,
                      title: 'Safety Network',
                      subtitle: 'No contacts yet',
                      trailing: const Icon(Icons.chevron_right,
                          color: AppColors.textMuted),
                    ),
                    _NotificationsTile(
                      enabled: _notificationsEnabled,
                      onToggle: (val) {
                        setState(() {
                          _notificationsEnabled = val;
                          AppSession.instance.notificationsEnabled = val;
                        });
                      },
                    ),
                  ]),
                ),
              ),

              // ── Logout ───────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
                  child: GestureDetector(
                    onTap: () {
                      AppSession.instance.clear();
                      context.go(AppRouter.roleSelection);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.critical.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.critical.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout,
                              color: AppColors.critical, size: 18),
                          SizedBox(width: 8),
                          Text('LOG OUT',
                              style: TextStyle(
                                  color: AppColors.critical,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1)),
                        ],
                      ),
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

SliverToBoxAdapter _sectionHeader(String text) => SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
        child: Text(text,
            style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2)),
      ),
    );

// ─────────────────────────────────────────────────────────
// Shared widgets (used by both citizen and officer profiles)
// ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
          ],
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> tiles;
  const _SettingsGroup({required this.tiles});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            tiles[i],
            if (i < tiles.length - 1)
              Divider(
                  height: 1,
                  indent: 52,
                  color: Colors.white.withValues(alpha: 0.07)),
          ]
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final _StatusChip? statusChip;
  final String? badge;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.statusChip,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    if (badge != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.high.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(badge!,
                            style: const TextStyle(
                                color: AppColors.high,
                                fontSize: 9,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          ?statusChip,
          ?trailing,
        ],
      ),
    );
  }
}

class _NotificationsTile extends StatelessWidget {
  final bool enabled;
  final ValueChanged<bool> onToggle;

  const _NotificationsTile({required this.enabled, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              enabled
                  ? Icons.notifications_active_outlined
                  : Icons.notifications_off_outlined,
              color: AppColors.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Notifications',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(enabled ? 'Push alerts enabled' : 'Push alerts disabled',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: onToggle,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            inactiveThumbColor: AppColors.textMuted,
          ),
        ],
      ),
    );
  }
}
