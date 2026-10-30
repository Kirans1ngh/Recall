import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
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
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top drag indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Platform badge + status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: platformColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(bookmark.platformEmoji, style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          bookmark.platform.toUpperCase(),
                          style: TextStyle(
                            color: platformColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        bookmark.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Title
              Text(
                bookmark.displayTitle,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),

              // URL link
              InkWell(
                onTap: () => _launchUrl(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          bookmark.url,
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new, size: 14, color: AppColors.primaryLight),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Summary
              if (bookmark.summary != null && bookmark.summary!.isNotEmpty) ...[
                const Text(
                  'Summary',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bookmark.summary!,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Key Points
              if (bookmark.keyPoints.isNotEmpty) ...[
                const Text(
                  'Key Points',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...bookmark.keyPoints.map(
                  (pt) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16, height: 1.2)),
                        Expanded(
                          child: Text(
                            pt,
                            style: const TextStyle(color: AppColors.text, fontSize: 13, height: 1.4),
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
                  'Tags',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: bookmark.tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#$t',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Created date
              Text(
                'Added on $dateFormatted',
                style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Action buttons: Open In Browser & Delete
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _launchUrl(context),
                      icon: const Icon(Icons.launch, size: 18),
                      label: const Text('Open Content'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.error.withValues(alpha: 0.15),
                      foregroundColor: AppColors.error,
                      padding: const EdgeInsets.all(14),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Delete bookmark',
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

