import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/scale_tap.dart';

class QuerySuggestions extends StatelessWidget {
  final List<String> suggestions;
  final ValueChanged<String> onSelected;

  const QuerySuggestions({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Explore Memory Graph',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 12),
          ...suggestions.map((q) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ScaleTap(
                  scaleDown: 0.98,
                  onTap: () => onSelected(q),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, size: 16, color: AppColors.cyanLight),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            q,
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        const Icon(Icons.north_west, size: 14, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
