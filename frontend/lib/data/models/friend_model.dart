import 'package:equatable/equatable.dart';

enum FriendActivity { safeCheckIn, reportedIncident, friendRequest, accepted, posted }

class FriendModel extends Equatable {
  final String id;
  final String name;
  final int mutualFriends;
  final double distanceKm;
  final String timeAgo;
  final FriendActivity activity;
  final String? activityDetail;
  final bool isOnline;

  const FriendModel({
    required this.id,
    required this.name,
    required this.mutualFriends,
    required this.distanceKm,
    required this.timeAgo,
    required this.activity,
    this.activityDetail,
    this.isOnline = false,
  });

  static final requests = [
    const FriendModel(
      id: '1', name: 'AYA SAMEH', mutualFriends: 38,
      distanceKm: 0.6, timeAgo: '3m ago',
      activity: FriendActivity.friendRequest,
    ),
    const FriendModel(
      id: '2', name: 'EYAD HESHAM', mutualFriends: 24,
      distanceKm: 2.5, timeAgo: '6h ago',
      activity: FriendActivity.friendRequest,
    ),
    const FriendModel(
      id: '3', name: 'ADAM AHMED', mutualFriends: 12,
      distanceKm: 1.0, timeAgo: '1d ago',
      activity: FriendActivity.friendRequest,
    ),
    const FriendModel(
      id: '4', name: 'MUSTAFA M.', mutualFriends: 28,
      distanceKm: 0.3, timeAgo: '2d ago',
      activity: FriendActivity.friendRequest,
    ),
  ];

  static final activityFeed = [
    const FriendModel(
      id: '1', name: 'Mark', mutualFriends: 0,
      distanceKm: 0.0, timeAgo: '10m ago',
      activity: FriendActivity.safeCheckIn,
      activityDetail: 'At office',
      isOnline: true,
    ),
    const FriendModel(
      id: '2', name: 'Jane', mutualFriends: 0,
      distanceKm: 0.6, timeAgo: '19m ago',
      activity: FriendActivity.reportedIncident,
      activityDetail: '0.6 km · 19m ago',
    ),
    const FriendModel(
      id: '3', name: 'Ahmed', mutualFriends: 0,
      distanceKm: 0.3, timeAgo: '22m ago',
      activity: FriendActivity.reportedIncident,
      activityDetail: '0.3 km · 22m ago',
    ),
    const FriendModel(
      id: '4', name: 'Judy', mutualFriends: 0,
      distanceKm: 2.4, timeAgo: '1h ago',
      activity: FriendActivity.accepted,
      activityDetail: '2.4 km · 1h ago',
    ),
    const FriendModel(
      id: '5', name: 'Amr', mutualFriends: 0,
      distanceKm: 0.0, timeAgo: '2h ago',
      activity: FriendActivity.posted,
      activityDetail: 'At home · 2h ago',
      isOnline: true,
    ),
    const FriendModel(
      id: '6', name: 'Ann', mutualFriends: 0,
      distanceKm: 0.0, timeAgo: '4h ago',
      activity: FriendActivity.posted,
      activityDetail: 'At office · 4h ago',
    ),
  ];

  @override
  List<Object?> get props => [id];
}
