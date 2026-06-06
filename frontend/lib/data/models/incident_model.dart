import 'package:equatable/equatable.dart';

enum IncidentPriority { critical, high, medium, low }
enum IncidentStatus { ongoing, resolved, pending, live }

class IncidentModel extends Equatable {
  final String id;
  final String title;
  final String location;
  final String sector;
  final IncidentPriority priority;
  final IncidentStatus status;
  final String timeAgo;
  final String? imageUrl;
  final bool aiVerified;
  final double lat;
  final double lng;

  const IncidentModel({
    required this.id,
    required this.title,
    required this.location,
    required this.sector,
    required this.priority,
    required this.status,
    required this.timeAgo,
    this.imageUrl,
    this.aiVerified = true,
    this.lat = 31.2,
    this.lng = 29.9,
  });

  static final mockList = [
    const IncidentModel(
      id: '93T2R0',
      title: 'Chemical Spill',
      location: 'Sector 4, Industrial District',
      sector: 'Industrial',
      priority: IncidentPriority.critical,
      status: IncidentStatus.live,
      timeAgo: '2 mins ago',
      aiVerified: true,
      lat: 31.215,
      lng: 29.945,
    ),
    const IncidentModel(
      id: '72U34K',
      title: 'Riot',
      location: 'Al Shatby, Gaish Rd',
      sector: 'Urban',
      priority: IncidentPriority.critical,
      status: IncidentStatus.ongoing,
      timeAgo: '5 mins ago',
      aiVerified: true,
      lat: 31.208,
      lng: 29.931,
    ),
    const IncidentModel(
      id: '24Y2L0',
      title: 'Car Collision',
      location: 'Al Soyouf Qebi, Montazah',
      sector: 'Traffic',
      priority: IncidentPriority.high,
      status: IncidentStatus.ongoing,
      timeAgo: '12 mins ago',
      aiVerified: true,
      lat: 31.298,
      lng: 30.025,
    ),
    const IncidentModel(
      id: '8A29V2',
      title: 'Infrastructure',
      location: 'Louran, Gaish Rd',
      sector: 'Infrastructure',
      priority: IncidentPriority.high,
      status: IncidentStatus.ongoing,
      timeAgo: '18 mins ago',
      aiVerified: true,
      lat: 31.200,
      lng: 29.910,
    ),
    const IncidentModel(
      id: 'X2L38R',
      title: 'Noise Complaint',
      location: 'Sector 7, Regional District',
      sector: 'Social',
      priority: IncidentPriority.medium,
      status: IncidentStatus.ongoing,
      timeAgo: '30 mins ago',
      aiVerified: false,
      lat: 31.190,
      lng: 29.950,
    ),
  ];

  static final citizenReports = [
    const IncidentModel(
      id: '93T2R0',
      title: 'Noise Complaint',
      location: '3 hours ago',
      sector: 'Unit Dispatched',
      priority: IncidentPriority.medium,
      status: IncidentStatus.ongoing,
      timeAgo: '3 hours ago',
    ),
    const IncidentModel(
      id: 'Y2K3R0',
      title: 'Infrastructure',
      location: '2 days ago',
      sector: 'Case Resolved',
      priority: IncidentPriority.low,
      status: IncidentStatus.resolved,
      timeAgo: '2 days ago',
    ),
  ];

  @override
  List<Object?> get props => [id];
}
