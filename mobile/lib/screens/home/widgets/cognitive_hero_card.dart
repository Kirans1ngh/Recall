import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/breathing_halo.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/scale_tap.dart';

class CognitiveHeroCard extends StatelessWidget {
  final int totalCount;
  final int completedCount;
  final int processingCount;
  final VoidCallback onTap;

  const CognitiveHeroCard({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.processingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: GlassContainer(
          borderRadius: 24,
          borderWidth: 1.2,
          borderGradient: const LinearGradient(
            colors: [
              Color(0x666366F1),
              Color(0x3306B6D4),
              Color(0x1AFFFFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          backgroundColor: AppColors.surface.withValues(alpha: 0.88),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              // Left Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.cyan.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.grain, size: 13, color: AppColors.cyanLight),
                          SizedBox(width: 6),
                          Text(
                            'Cognitive Retention',
                            style: TextStyle(
                              color: AppColors.cyanLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '$totalCount Memories',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      processingCount > 0
                          ? '$processingCount items synthesizing now'
                          : '$completedCount indexed in vector vault',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),

              // Right Graphic: Smart Ring with subtle Breathing Halo
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    BreathingHalo(
                      animate: processingCount > 0,
                      glowColor: processingCount > 0 ? AppColors.cyan : AppColors.primary,
                      maxBlur: 16,
                      maxSpread: 4,
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    Image.asset(
                      'assets/images/smart_ring.png',
                      width: 82,
                      height: 82,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.track_changes,
                        size: 44,
                        color: AppColors.cyanLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
