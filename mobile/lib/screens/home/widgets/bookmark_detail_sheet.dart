import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/scale_tap.dart';
import '../../../models/bookmark.dart';

class BookmarkDetailSheet extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onDelete;

  const BookmarkDetailSheet({
    super.key,
    required this.bookmark,
    required this.onDelete,
  });

  Future<void> _launchUrl(BuildContext context) async {
    final uri = Uri.tryParse(bookmark.url);
    if (uri != null) {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open link in browser')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final platformColor = AppColors.getPlatformColor(bookmark.platform);
    final statusColor = AppColors.getStatusColor(bookmark.status);
    final dateFormatted = DateFormat.yMMMd().add_jm().format(bookmark.createdAt);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Platform Badge & Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: platformColor.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: platformColor.withValues(alpha: 0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(bookmark.platformEmoji, style: const TextStyle(fontSize: 13)),
                          const SizedBox(width: 6),
                          Text(
                            bookmark.platform.toUpperCase(),
                            style: TextStyle(
                              color: platformColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            bookmark.status.toUpperCase(),
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Title
                Text(
                  bookmark.displayTitle,
                  style: const TextStyle(
                    color: AppColors.text,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Link Preview
                ScaleTap(
                  onTap: () => _launchUrl(context),
                  scaleDown: 0.98,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: AppColors.cyanLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            bookmark.url,
                            style: const TextStyle(
                              color: AppColors.cyanLight,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.open_in_new, size: 14, color: AppColors.cyanLight),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Cognitive Summary
                if (bookmark.summary != null && bookmark.summary!.isNotEmpty) ...[
                  const Text(
                    'Executive Summary',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GlassContainer(
                    borderRadius: 16,
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      bookmark.summary!,
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        height: 1.55,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Key Takeaways
                if (bookmark.keyPoints.isNotEmpty) ...[
                  const Text(
                    'Core Cognitive Takeaways',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...bookmark.keyPoints.map(
                    (pt) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2, right: 10),
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 12, color: AppColors.cyanLight),
                          ),
                          Expanded(
                            child: Text(
                              pt,
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Tags
                if (bookmark.tags.isNotEmpty) ...[
                  const Text(
                    'Categorized Topics',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: bookmark.tags.map((t) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          '#$t',
                          style: const TextStyle(
                            color: AppColors.cyanLight,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),
                ],

                // Stored Timestamp
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Indexed on $dateFormatted',
                      style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ScaleTap(
                        scaleDown: 0.96,
                        onTap: () => _launchUrl(context),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: AppColors.aiSynthesisGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.open_in_browser, size: 18, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Open External Content',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ScaleTap(
                      scaleDown: 0.92,
                      onTap: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.35),
                            width: 1,
                          ),
                        ),
                        child: const Center(
                          child: Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
