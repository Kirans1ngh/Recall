import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/breathing_halo.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/scale_tap.dart';
import '../../../models/bookmark.dart';

class BookmarkCard extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const BookmarkCard({
    super.key,
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final platformColor = AppColors.getPlatformColor(bookmark.platform);
    final statusColor = AppColors.getStatusColor(bookmark.status);
    final formattedDate = DateFormat.MMMd().format(bookmark.createdAt);
    final isProcessing = bookmark.isProcessing || bookmark.isPending;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ScaleTap(
        onTap: onTap,
        scaleDown: 0.98,
        child: GlassContainer(
          borderRadius: 20,
          borderWidth: 1.0,
          borderGradient: isProcessing
              ? const LinearGradient(
                  colors: [AppColors.cyan, AppColors.primary, AppColors.border],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Platform Badge + Cognitive Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: platformColor.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: platformColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bookmark.platformEmoji,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bookmark.platform.toLowerCase(),
                          style: TextStyle(
                            color: platformColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status Indicator with Breathing Halo when processing
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BreathingHalo(
                        animate: isProcessing,
                        glowColor: statusColor,
                        maxBlur: 10,
                        maxSpread: 2.5,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isProcessing ? 'analyzing...' : bookmark.status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                bookmark.displayTitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),

              // Summary
              if (bookmark.summary != null && bookmark.summary!.trim().isNotEmpty) ...[
                Text(
                  bookmark.summary!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                    letterSpacing: -0.1,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Tags
              if (bookmark.tags.isNotEmpty) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    ...bookmark.tags.take(3).map((tag) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              color: AppColors.cyanLight,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )),
                    if (bookmark.tags.length > 3)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                        child: Text(
                          '+${bookmark.tags.length - 3}',
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // Footer: Date + Open Arrow Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 13,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: const TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
