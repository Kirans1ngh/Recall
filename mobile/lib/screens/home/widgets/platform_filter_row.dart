import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/scale_tap.dart';

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
      height: 40,
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

          return ScaleTap(
            scaleDown: 0.94,
            onTap: () {
              onPlatformSelected(isAll ? null : platform);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.22)
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? color.withValues(alpha: 0.7) : AppColors.border,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  isAll ? 'All' : platform[0].toUpperCase() + platform.substring(1),
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
