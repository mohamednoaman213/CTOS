import 'package:equatable/equatable.dart';
import '../../core/session/app_session.dart';

enum UserRole { citizen, officer }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String title;
  final UserRole role;
  final String? avatarUrl;
  final String address;
  final bool isOnline;
  final int reportCount;
  final double aiScore;
  final String impactGrade;
  final int level;

  const UserModel({
    required this.id,
    required this.name,
    required this.title,
    required this.role,
    this.avatarUrl,
    required this.address,
    this.isOnline = true,
    this.reportCount = 0,
    this.aiScore = 0.0,
    this.impactGrade = 'N/A',
    this.level = 1,
  });

  factory UserModel.fromSession() {
    final s = AppSession.instance;
    final isCitizen = s.role == 'citizen';
    final nameStr = s.name.isEmpty ? 'User' : s.name;
    return UserModel(
      id: 'CTOS-${(nameStr.hashCode.abs() % 9000) + 1000}',
      name: nameStr,
      title: isCitizen ? 'Citizen Reporter' : 'Government Official',
      role: isCitizen ? UserRole.citizen : UserRole.officer,
      address: '',
      isOnline: true,
      reportCount: s.reportCount,
      aiScore: s.reportCount > 0 ? 72.0 : 0.0,
      impactGrade: s.reportCount > 5
          ? 'A'
          : s.reportCount > 0
              ? 'B'
              : 'N/A',
      level: 1 + (s.reportCount ~/ 10),
    );
  }

  @override
  List<Object?> get props => [id, name, role];
}
