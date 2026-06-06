import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SearchBarWidget extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const SearchBarWidget({
    super.key,
    this.hint = 'Search location or incident...',
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: TextField(
        onChanged: onChanged,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }
}
