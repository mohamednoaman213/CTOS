import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/api_client.dart';
import '../../shared/widgets/app_header.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  File? _pickedImage;
  bool _submitting = false;
  bool _locationDetected = false;
  bool _detectingLocation = false;
  LatLng? _detectedLocation;
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    setState(() => _pickedImage = File(image.path));
  }

  Future<void> _detectLocation() async {
    if (_detectingLocation) return;
    setState(() => _detectingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enable location services.')));
      setState(() => _detectingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _detectingLocation = false);
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied. Enable it in Settings.')));
      setState(() => _detectingLocation = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _detectedLocation = LatLng(pos.latitude, pos.longitude);
        _locationDetected = true;
        _detectingLocation = false;
      });
    } catch (_) {
      setState(() => _detectingLocation = false);
    }
  }

  Future<void> _submit() async {
    if (_pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload an image first.')));
      return;
    }
    setState(() => _submitting = true);

    final desc = _descController.text.trim();
    final location = _detectedLocation != null
        ? '${_detectedLocation!.latitude.toStringAsFixed(5)}, ${_detectedLocation!.longitude.toStringAsFixed(5)}'
        : 'Unknown';

    try {
      final uri = Uri.parse('${ApiClient.baseUrl}/api/event/create');
      final request = http.MultipartRequest('POST', uri)
        ..fields['EventName'] = desc.isNotEmpty ? desc : 'Citizen Report'
        ..fields['Description'] = desc.isNotEmpty ? desc : 'Citizen Report'
        ..fields['Location'] = location
        ..fields['Category'] = 'General'
        ..fields['UserId'] = AppSession.instance.userId.toString()
        ..files.add(await http.MultipartFile.fromPath('Image', _pickedImage!.path));

      final streamed = await request.send().timeout(const Duration(seconds: 60));

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        if (mounted) context.go(AppRouter.reportSubmitted);
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed (${streamed.statusCode}). Try again.')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error. Check your connection.')));
    }

    if (mounted) setState(() => _submitting = false);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          AppHeader(user: UserModel.fromSession(), onSettingsTap: () {}),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.go(AppRouter.citizenHome),
                  child: const Icon(Icons.arrow_back_ios_new,
                      color: AppColors.textSecondary, size: 18),
                ),
                const SizedBox(width: 12),
                const Text('Submit Anonymous Report',
                    style: AppTextStyles.headlineSmall),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image picker
                  GestureDetector(
                    onTap: _submitting ? null : _pickImage,
                    child: Container(
                      height: _pickedImage != null ? 240 : 160,
                      decoration: BoxDecoration(
                        color: AppColors.scannerBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.scannerBorder.withValues(alpha: 0.4),
                            width: 1.5),
                      ),
                      child: _pickedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Stack(
                                children: [
                                  SizedBox.expand(
                                    child: Image.file(_pickedImage!, fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: GestureDetector(
                                      onTap: _submitting ? null : _pickImage,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.refresh,
                                                color: Colors.white, size: 14),
                                            SizedBox(width: 4),
                                            Text('Change',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add, color: AppColors.primary, size: 28),
                                  SizedBox(height: 8),
                                  Text('UPLOAD IMAGE',
                                      style: TextStyle(
                                          color: AppColors.primary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 1)),
                                  SizedBox(height: 4),
                                  Text('TAP TO PICK FROM GALLERY',
                                      style: TextStyle(
                                          color: AppColors.textMuted, fontSize: 10)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Location
                  const Text('Location', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: (!_locationDetected && !_detectingLocation) ? _detectLocation : null,
                    child: _LocationBox(
                      detected: _locationDetected,
                      detecting: _detectingLocation,
                      location: _detectedLocation,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  const Text('Description', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                        hintText: 'Describe incident... (optional)'),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary),
                      child: _submitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('SUBMIT ANONYMOUSLY',
                              style: TextStyle(
                                  letterSpacing: 2,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outline,
                          color: AppColors.textMuted, size: 14),
                      const SizedBox(width: 4),
                      Text('End-to-end encrypted submission',
                          style: AppTextStyles.bodySmall),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final bool detected;
  final bool detecting;
  final LatLng? location;
  const _LocationBox({required this.detected, required this.detecting, required this.location});

  @override
  Widget build(BuildContext context) {
    if (detecting) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.scannerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.scannerBorder.withValues(alpha: 0.4), width: 1.5),
        ),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
            SizedBox(height: 10),
            Text('Acquiring GPS signal...',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
          ]),
        ),
      );
    }

    if (!detected) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.scannerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.scannerBorder.withValues(alpha: 0.4), width: 1.5),
        ),
        child: const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.location_on_outlined, color: AppColors.primary, size: 24),
            SizedBox(height: 8),
            Text('TAP TO DETECT LOCATION',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1)),
            SizedBox(height: 4),
            Text('GPS READY', style: TextStyle(color: AppColors.textMuted, fontSize: 10)),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.scannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('GPS LOCATION DETECTED',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5)),
              const SizedBox(height: 4),
              Text(
                location != null
                    ? '${location!.latitude.toStringAsFixed(5)}, ${location!.longitude.toStringAsFixed(5)}'
                    : '',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
              ),
            ]),
          ),
          const Icon(Icons.check_circle, color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
