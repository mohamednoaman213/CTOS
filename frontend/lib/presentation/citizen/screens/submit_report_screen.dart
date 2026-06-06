import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_router.dart';
import '../../../core/session/app_session.dart';
import '../../../data/models/incident_model.dart';
import '../../../data/models/user_model.dart';
import '../../shared/widgets/app_header.dart';

enum AnalysisStep {
  none,
  uploading,
  analyzing,
  categorized,
  privacyFilter,
  categorization,
  fabrication,
  priority,
  done
}

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  AnalysisStep _step = AnalysisStep.none;
  File? _pickedImage;
  bool _locationDetected = false;
  bool _detectingLocation = false;
  LatLng? _detectedLocation;
  String _mlCategory = 'GENERAL INCIDENT';
  double _mlConfidence = 0.0;
  final _descController = TextEditingController();
  final _picker = ImagePicker();

  final _analysisSteps = [
    'Privacy Filter Successful',
    'Categorization Successful',
    'Fabrication-Scan Successful',
    'Priority Assignment Successful',
    'SENTINEL DONE',
  ];

  int get _stepsCompleted {
    switch (_step) {
      case AnalysisStep.privacyFilter:
        return 1;
      case AnalysisStep.categorization:
        return 2;
      case AnalysisStep.fabrication:
        return 3;
      case AnalysisStep.priority:
        return 4;
      case AnalysisStep.done:
        return 5;
      default:
        return 0;
    }
  }

  Future<void> _pickImageFromGallery() async {
    if (_step != AnalysisStep.none) return;
    try {
      final XFile? image =
          await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      setState(() {
        _pickedImage = File(image.path);
        _step = AnalysisStep.uploading;
      });
      await _runAnalysis();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not access photos. Check permissions.')),
        );
      }
    }
  }

  String _categorizeByPath(String path) {
    final p = path.toLowerCase();
    if (p.contains('fire') || p.contains('flame') || p.contains('smoke')) {
      return 'FIRE HAZARD';
    }
    if (p.contains('car') || p.contains('vehicle') || p.contains('crash') || p.contains('accident')) {
      return 'VEHICLE ACCIDENT';
    }
    if (p.contains('road') || p.contains('street') || p.contains('pothole')) {
      return 'ROAD HAZARD';
    }
    if (p.contains('flood') || p.contains('water') || p.contains('storm')) {
      return 'FLOOD HAZARD';
    }
    if (p.contains('building') || p.contains('construction') || p.contains('infra')) {
      return 'INFRASTRUCTURE DAMAGE';
    }
    return 'GENERAL INCIDENT';
  }

  IncidentPriority _priorityFromCategory(String category) {
    if (category.contains('FIRE')) return IncidentPriority.critical;
    if (category.contains('ACCIDENT') || category.contains('FLOOD')) {
      return IncidentPriority.high;
    }
    return IncidentPriority.medium;
  }

  Future<void> _runAnalysis() async {
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _step = AnalysisStep.analyzing);

    if (_pickedImage != null) {
      _mlCategory = _categorizeByPath(_pickedImage!.path);
      _mlConfidence = 85.0;
    }

    setState(() => _step = AnalysisStep.categorized);
    await Future.delayed(const Duration(milliseconds: 700));
    setState(() => _step = AnalysisStep.privacyFilter);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _step = AnalysisStep.categorization);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _step = AnalysisStep.fabrication);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _step = AnalysisStep.priority);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _step = AnalysisStep.done);
  }

  Future<void> _detectLocation() async {
    if (_detectingLocation) return;
    setState(() => _detectingLocation = true);

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enable location services.')),
        );
      }
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Location permission denied. Enable it in Settings.')),
        );
      }
      setState(() => _detectingLocation = false);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _detectedLocation = LatLng(pos.latitude, pos.longitude);
        _locationDetected = true;
        _detectingLocation = false;
      });
    } catch (_) {
      setState(() => _detectingLocation = false);
    }
  }

  void _submitReport() {
    final desc = _descController.text.trim();
    final title = desc.isNotEmpty
        ? (desc.length > 30 ? '${desc.substring(0, 30)}...' : desc)
        : _mlCategory != 'GENERAL INCIDENT'
            ? _mlCategory
            : 'Citizen Report';

    final report = IncidentModel(
      id: DateTime.now().millisecondsSinceEpoch.toString().substring(7),
      title: title,
      location: _detectedLocation != null
          ? '${_detectedLocation!.latitude.toStringAsFixed(4)}, ${_detectedLocation!.longitude.toStringAsFixed(4)}'
          : 'Unknown',
      sector: _mlCategory,
      priority: _step == AnalysisStep.done
          ? _priorityFromCategory(_mlCategory)
          : IncidentPriority.medium,
      status: IncidentStatus.pending,
      timeAgo: 'Just now',
      aiVerified: _step == AnalysisStep.done,
      lat: _detectedLocation?.latitude ?? 31.2,
      lng: _detectedLocation?.longitude ?? 29.9,
    );

    AppSession.instance.addReport(report);
    context.go(AppRouter.reportSubmitted);
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
          AppHeader(
            user: UserModel.fromSession(),
            onSettingsTap: () {},
          ),
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
                  GestureDetector(
                    onTap: _step == AnalysisStep.none
                        ? _pickImageFromGallery
                        : null,
                    child: _ImageUploadBox(
                      step: _step,
                      stepsCompleted: _stepsCompleted,
                      steps: _analysisSteps,
                      pickedImage: _pickedImage,
                      mlCategory: _mlCategory,
                      mlConfidence: _mlConfidence,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Location', style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: (!_locationDetected && !_detectingLocation)
                        ? _detectLocation
                        : null,
                    child: _LocationBox(
                      detected: _locationDetected,
                      detecting: _detectingLocation,
                      location: _detectedLocation,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Description',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _descController,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Describe incident... (optional)',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text(
                      'SUBMIT ANONYMOUSLY',
                      style: TextStyle(
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700,
                      ),
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

class _ImageUploadBox extends StatelessWidget {
  final AnalysisStep step;
  final int stepsCompleted;
  final List<String> steps;
  final File? pickedImage;
  final String mlCategory;
  final double mlConfidence;

  const _ImageUploadBox({
    required this.step,
    required this.stepsCompleted,
    required this.steps,
    required this.pickedImage,
    required this.mlCategory,
    required this.mlConfidence,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = step.index >= AnalysisStep.analyzing.index;

    return Container(
      height: hasImage ? 220 : 160,
      decoration: BoxDecoration(
        color: AppColors.scannerBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.scannerBorder.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          if (hasImage && pickedImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox.expand(
                child: Image.file(pickedImage!, fit: BoxFit.cover),
              ),
            )
          else if (hasImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: const Color(0xFF2A3A40),
                child: Center(
                  child: Icon(Icons.image_outlined,
                      size: 80,
                      color: AppColors.textMuted.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ..._corners(),
          if (!hasImage)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (step == AnalysisStep.uploading)
                    const CircularProgressIndicator(
                        color: AppColors.primary, strokeWidth: 2)
                  else
                    const Icon(Icons.add, color: AppColors.primary, size: 28),
                  const SizedBox(height: 8),
                  const Text('UPLOAD IMAGE',
                      style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  const SizedBox(height: 4),
                  const Text('TAP TO PICK FROM GALLERY',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 10)),
                ],
              ),
            ),
          if (hasImage && step != AnalysisStep.analyzing)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (step == AnalysisStep.categorized) ...[
                      _InfoRow('Category', mlCategory),
                      _InfoRow(
                        'Confidence',
                        mlConfidence > 0
                            ? '${mlConfidence.toInt()}%'
                            : 'PROCESSING',
                      ),
                      _InfoRow('AI Validation', 'PROCESSING'),
                    ] else if (step.index > AnalysisStep.categorized.index) ...[
                      for (int i = 0;
                          i < stepsCompleted && i < steps.length;
                          i++)
                        _StepRow(steps[i],
                            i == stepsCompleted - 1 &&
                                step != AnalysisStep.done),
                    ],
                  ],
                ),
              ),
            ),
          if (step == AnalysisStep.analyzing)
            const Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: Text('AI analysis in progress...',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _corners() {
    const c = AppColors.primary;
    const r = 12.0;
    const len = 18.0;
    return [
      Positioned(top: r, left: r, child: _CornerMark(c, len, 0)),
      Positioned(top: r, right: r, child: _CornerMark(c, len, 1)),
      Positioned(bottom: r, left: r, child: _CornerMark(c, len, 2)),
      Positioned(bottom: r, right: r, child: _CornerMark(c, len, 3)),
    ];
  }
}

class _CornerMark extends StatelessWidget {
  final Color color;
  final double len;
  final int pos;
  const _CornerMark(this.color, this.len, this.pos);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: len,
      height: len,
      child: CustomPaint(painter: _CornerPainter(color: color, pos: pos)),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final int pos;
  _CornerPainter({required this.color, required this.pos});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;
    final w = size.width;
    final h = size.height;
    switch (pos) {
      case 0:
        canvas.drawLine(Offset(0, h), const Offset(0, 0), p);
        canvas.drawLine(const Offset(0, 0), Offset(w, 0), p);
        break;
      case 1:
        canvas.drawLine(const Offset(0, 0), Offset(w, 0), p);
        canvas.drawLine(Offset(w, 0), Offset(w, h), p);
        break;
      case 2:
        canvas.drawLine(const Offset(0, 0), Offset(0, h), p);
        canvas.drawLine(Offset(0, h), Offset(w, h), p);
        break;
      case 3:
        canvas.drawLine(Offset(0, h), Offset(w, h), p);
        canvas.drawLine(Offset(w, h), Offset(w, 0), p);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text('$label: $value',
          style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String text;
  final bool isLatest;
  const _StepRow(this.text, this.isLatest);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Text(text,
          style: TextStyle(
              color: isLatest ? AppColors.primary : AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _LocationBox extends StatelessWidget {
  final bool detected;
  final bool detecting;
  final LatLng? location;
  const _LocationBox(
      {required this.detected,
      required this.detecting,
      required this.location});

  @override
  Widget build(BuildContext context) {
    if (detecting) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.scannerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.scannerBorder.withValues(alpha: 0.4),
              width: 1.5),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                  color: AppColors.primary, strokeWidth: 2),
              SizedBox(height: 10),
              Text('Acquiring GPS signal...',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12)),
            ],
          ),
        ),
      );
    }

    if (!detected) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          color: AppColors.scannerBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.scannerBorder.withValues(alpha: 0.4),
              width: 1.5),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  color: AppColors.primary, size: 24),
              SizedBox(height: 8),
              Text('TAP TO DETECT LOCATION',
                  style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1)),
              SizedBox(height: 4),
              Text('GPS READY',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 10)),
            ],
          ),
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
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.location_on,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.check_circle,
              color: AppColors.primary, size: 20),
        ],
      ),
    );
  }
}
