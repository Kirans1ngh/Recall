import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class PlatformFilterRow extends StatelessWidget {
  final List<String> platforms;
  final String? selectedPlatform;
  final ValueChanged<String?> onPlatformSelected;

  const PlatformFilterRow({
    super.key,
    required this.platforms,
    required this.selectedPlatform,
    required this.onPlatformSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (platforms.isEmpty) {
      return const SizedBox.shrink();
    }

    final allFilters = ['all', ...platforms];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: allFilters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final platform = allFilters[index];
          final isAll = platform == 'all';
          final isSelected = isAll ? selectedPlatform == null : selectedPlatform == platform;
          final color = isAll ? AppColors.primary : AppColors.getPlatformColor(platform);

          return ChoiceChip(
            label: Text(
              isAll ? 'All' : platform[0].toUpperCase() + platform.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 13,
              ),
            ),
            selected: isSelected,
            onSelected: (_) {
              onPlatformSelected(isAll ? null : platform);
            },
            selectedColor: color.withValues(alpha: 0.35),
            backgroundColor: AppColors.surface,
            side: BorderSide(
              color: isSelected ? color : AppColors.surfaceLight,
              width: 1,
            ),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          );
        },
      ),
    );
  }
}
