import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';

class AiAnswerCard extends StatelessWidget {
  final String answer;

  const AiAnswerCard({super.key, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GlassContainer(
        borderRadius: 20,
        borderWidth: 1.5,
        borderGradient: AppColors.aiSynthesisGradient,
        backgroundColor: AppColors.surface.withValues(alpha: 0.9),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.aiSynthesisGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Cognitive Synthesis',
                  style: TextStyle(
                    color: AppColors.cyanLight,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'AI Answer',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              answer,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                height: 1.55,
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
