import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../data/models/unit_model.dart';
import '../bloc/officer_bloc.dart';
import '../bloc/officer_state.dart';

class UnitsScreen extends StatelessWidget {
  const UnitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OfficerBloc, OfficerState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('UNITS', style: AppTextStyles.headlineLarge),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: state.units.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _UnitTile(unit: state.units[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UnitTile extends StatefulWidget {
  final UnitModel unit;
  const _UnitTile({required this.unit});

  @override
  State<_UnitTile> createState() => _UnitTileState();
}

class _UnitTileState extends State<_UnitTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isAvailable = widget.unit.status == UnitStatus.available;
    final statusColor =
        isAvailable ? AppColors.onlineGreen : AppColors.occupiedOrange;
    final statusLabel = isAvailable ? 'AVAILABLE' : 'OCCUPIED';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.local_police_outlined,
                          color: AppColors.textSecondary, size: 24),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.surface, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.unit.name,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: AnimatedRotation(
                    turns: _expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right,
                        color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() => _expanded = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Backup requested for ${widget.unit.name}'),
                        backgroundColor: AppColors.high,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.campaign_outlined, size: 16),
                  label: const Text('REQUEST BACKUP',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.high,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
