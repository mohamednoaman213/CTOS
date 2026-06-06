import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/incident_model.dart';
import '../bloc/citizen_bloc.dart';
import '../bloc/citizen_state.dart';

class CitizenMapScreen extends StatefulWidget {
  const CitizenMapScreen({super.key});

  @override
  State<CitizenMapScreen> createState() => _CitizenMapScreenState();
}

class _CitizenMapScreenState extends State<CitizenMapScreen> {
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
    return BlocBuilder<CitizenBloc, CitizenState>(
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
                    ...IncidentModel.mockList.map(
                      (inc) => Marker(
                        point: LatLng(inc.lat, inc.lng),
                        width: 36,
                        height: 36,
                        child: _IncidentPin(priority: inc.priority),
                      ),
                    ),
                    if (_myLocation != null)
                      Marker(
                        point: _myLocation!,
                        width: 40,
                        height: 40,
                        child: const _MyLocationPin(),
                      ),
                  ],
                ),
              ],
            ),
            if (state.alertMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _AlertBanner(message: state.alertMessage!),
              ),
            Positioned(
              bottom: 20,
              right: 16,
              child: _MapFabs(
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

class _MyLocationPin extends StatelessWidget {
  const _MyLocationPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.2),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: const Icon(Icons.my_location,
          color: AppColors.primary, size: 20),
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

class _MapFabs extends StatelessWidget {
  final bool locating;
  final VoidCallback onLocate;
  const _MapFabs({required this.locating, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'citizen_locate',
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
          heroTag: 'citizen_navigate',
          onPressed: () {},
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.navigation,
              color: AppColors.background, size: 20),
        ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  final String message;
  const _AlertBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A0A0A),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.critical.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.critical, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'HIGH PRIORITY: CAR CRASH',
                        style: AppTextStyles.titleLarge
                            .copyWith(color: AppColors.critical),
                      ),
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
                const SizedBox(height: 2),
                Text(message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
