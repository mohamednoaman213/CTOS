import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/friend_model.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_state.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CitizenBloc, CitizenState>(
      builder: (context, state) {
        return Column(
          children: [
            // Tab bar
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: AppColors.background,
                unselectedLabelColor: AppColors.textSecondary,
                labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Friends'),
                  Tab(text: 'Requests'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _FriendActivityTab(items: state.friendActivity),
                  _FriendRequestsTab(items: state.friendRequests),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FriendActivityTab extends StatelessWidget {
  final List<FriendModel> items;
  const _FriendActivityTab({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
          child: Text('No friend activity', style: AppTextStyles.bodyMedium));
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _ActivityItem(friend: items[i]),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final FriendModel friend;
  const _ActivityItem({required this.friend});

  @override
  Widget build(BuildContext context) {
    String activityText;
    IconData activityIcon;
    Color iconColor;

    switch (friend.activity) {
      case FriendActivity.safeCheckIn:
        activityText = '${friend.name} checked in safe';
        activityIcon = Icons.check_circle_outline;
        iconColor = AppColors.medium;
        break;
      case FriendActivity.reportedIncident:
        activityText = '${friend.name} reported an incident';
        activityIcon = Icons.warning_amber_outlined;
        iconColor = AppColors.high;
        break;
      case FriendActivity.accepted:
        activityText = '${friend.name} accepted your request';
        activityIcon = Icons.person_add_outlined;
        iconColor = AppColors.primary;
        break;
      case FriendActivity.posted:
        activityText = '${friend.name} posted: "Just heard abo..."';
        activityIcon = Icons.chat_bubble_outline;
        iconColor = AppColors.textSecondary;
        break;
      default:
        activityText = friend.name;
        activityIcon = Icons.info_outline;
        iconColor = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              if (friend.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: AppColors.onlineGreen,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activityText, style: AppTextStyles.titleMedium),
                const SizedBox(height: 2),
                Text(friend.activityDetail ?? friend.timeAgo,
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          Icon(activityIcon, color: iconColor, size: 20),
        ],
      ),
    );
  }
}

class _FriendRequestsTab extends StatelessWidget {
  final List<FriendModel> items;
  const _FriendRequestsTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            'Incoming Requests (${items.length})',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RequestCard(friend: items[i]),
          ),
        ),
      ],
    );
  }
}

class _RequestCard extends StatefulWidget {
  final FriendModel friend;
  const _RequestCard({required this.friend});

  @override
  State<_RequestCard> createState() => _RequestCardState();
}

class _RequestCardState extends State<_RequestCard> {
  bool _responded = false;

  @override
  Widget build(BuildContext context) {
    if (_responded) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.surfaceLight,
                child: Icon(Icons.person, color: AppColors.textSecondary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.friend.name,
                        style: AppTextStyles.titleLarge
                            .copyWith(fontWeight: FontWeight.w700)),
                    Text(
                        '${widget.friend.mutualFriends} Mutual Friends',
                        style: AppTextStyles.bodySmall),
                    Text(
                        '${widget.friend.distanceKm} km away',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _responded = true),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.border),
                    foregroundColor: AppColors.textSecondary,
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => setState(() => _responded = true),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
