import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/incident_model.dart';
import '../bloc/officer_bloc.dart';
import '../bloc/officer_event.dart';
import '../bloc/officer_state.dart';

class OfficerMapScreen extends StatefulWidget {
  const OfficerMapScreen({super.key});

  @override
  State<OfficerMapScreen> createState() => _OfficerMapScreenState();
}

class _OfficerMapScreenState extends State<OfficerMapScreen> {
  final _mapController = MapController();
  LatLng? _myLocation;
  bool _locating = false;

  static const _defaultCenter = LatLng(31.2001, 29.9187);

  Future<void> _goToMyLocation() async {
    if (_locating) return;
    setState(() => _locating = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
      }
      setState(() => _locating = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _locating = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permission denied. Enable it in Settings.')),
        );
      }
      setState(() => _locating = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final loc = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _myLocation = loc;
        _locating = false;
      });
      _mapController.move(loc, 16);
    } catch (_) {
      setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfficerBloc, OfficerState>(
      builder: (context, state) {
        return Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 13,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ctos.app',
                ),
                MarkerLayer(
                  markers: [
                    ...state.incidents.map(
                      (inc) => Marker(
                        point: LatLng(inc.lat, inc.lng),
                        width: 38,
                        height: 38,
                        child: _IncidentPin(priority: inc.priority),
                      ),
                    ),
                    if (_myLocation != null)
                      Marker(
                        point: _myLocation!,
                        width: 42,
                        height: 42,
                        child: const _OfficerPin(),
                      ),
                    if (state.isResponding && _myLocation != null)
                      Marker(
                        point: const LatLng(31.208, 29.931),
                        width: 42,
                        height: 42,
                        child: const _DestinationPin(),
                      ),
                  ],
                ),
                if (state.isResponding)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: [
                          _myLocation ?? _defaultCenter,
                          const LatLng(31.208, 29.931),
                        ],
                        color: AppColors.primary,
                        strokeWidth: 4,
                      ),
                    ],
                  ),
              ],
            ),
            if (state.alertMessage != null && !state.isResponding)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _OfficerAlertBanner(
                  message: state.alertMessage!,
                  incidentId: state.alertIncidentId ?? '',
                  onRespond: () => context.read<OfficerBloc>().add(
                        RespondToIncidentEvent(state.alertIncidentId ?? ''),
                      ),
                ),
              ),
            if (state.isResponding)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _NavigationBanner(),
              ),
            if (state.isResponding)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: _TurnByTurnCard(),
              ),
            Positioned(
              bottom: state.isResponding ? 120 : 20,
              right: 16,
              child: _NavigationFabs(
                locating: _locating,
                onLocate: _goToMyLocation,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _OfficerPin extends StatelessWidget {
  const _OfficerPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: const Icon(Icons.local_police,
          color: AppColors.primary, size: 20),
    );
  }
}

class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.critical.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.critical, width: 2),
      ),
      child: const Icon(Icons.flag, color: AppColors.critical, size: 20),
    );
  }
}

class _IncidentPin extends StatelessWidget {
  final IncidentPriority priority;
  const _IncidentPin({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (priority) {
      case IncidentPriority.critical:
        color = AppColors.critical;
        icon = Icons.warning_amber_rounded;
        break;
      case IncidentPriority.high:
        color = AppColors.high;
        icon = Icons.report_problem_outlined;
        break;
      case IncidentPriority.medium:
        color = AppColors.medium;
        icon = Icons.info_outline;
        break;
      default:
        color = AppColors.primary;
        icon = Icons.location_on_outlined;
    }
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }
}

class _OfficerAlertBanner extends StatelessWidget {
  final String message;
  final String incidentId;
  final VoidCallback onRespond;

  const _OfficerAlertBanner({
    required this.message,
    required this.incidentId,
    required this.onRespond,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.critical.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.critical, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(message,
                          style: AppTextStyles.titleLarge
                              .copyWith(color: AppColors.critical)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.live,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                Text('Multiple reports of disturbance at Street 45',
                    style: AppTextStyles.bodySmall),
                Text('AI Confidence: 87%', style: AppTextStyles.bodySmall),
                const SizedBox(height: 2),
                Text('0.1 km · 2m ago',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onRespond,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.medium.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: AppColors.medium.withValues(alpha: 0.5)),
              ),
              child: const Text(
                'Respond',
                style: TextStyle(
                  color: AppColors.medium,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A2A),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text('RESPONDING TO INCIDENT: RIOT',
                        style: AppTextStyles.titleLarge),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.live,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('LIVE',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('High priority incident. Backup is on the way.',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TurnByTurnCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.turn_right, color: AppColors.primary, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('TURN RIGHT AFTER: 500m',
                    style: AppTextStyles.titleLarge),
                Text('Towards FAYROUZ STREET',
                    style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationFabs extends StatelessWidget {
  final bool locating;
  final VoidCallback onLocate;
  const _NavigationFabs({required this.locating, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'officer_locate',
          onPressed: onLocate,
          backgroundColor: AppColors.surface,
          child: locating
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: AppColors.primary, strokeWidth: 2),
                )
              : const Icon(Icons.my_location,
                  color: AppColors.primary, size: 20),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'officer_nav',
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.navigation,
              color: AppColors.background, size: 20),
        ),
      ],
    );
  }
}
