import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/scale_tap.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../models/bookmark.dart';
import '../../providers/bookmarks_provider.dart';
import '../settings/server_settings_dialog.dart';
import 'widgets/bookmark_card.dart';
import 'widgets/bookmark_detail_sheet.dart';
import 'widgets/platform_filter_row.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarksProvider>().fetchBookmarks();
    });
  }

  void _showDetailSheet(Bookmark bookmark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BookmarkDetailSheet(
          bookmark: bookmark,
          onDelete: () => _confirmDelete(bookmark),
        );
      },
    );
  }

  void _confirmDelete(Bookmark bookmark) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Delete Bookmark', style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to delete "${bookmark.displayTitle}"?',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final provider = context.read<BookmarksProvider>();
                Navigator.pop(context);
                try {
                  await provider.deleteBookmark(bookmark.id);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Bookmark deleted')),
                  );
                } catch (e) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Failed to delete: $e')),
                  );
                }
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bookmarks'),
            Text(
              '${provider.totalBookmarksCount} saved memory items',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          ScaleTap(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => const ServerSettingsDialog(),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.tune_outlined, size: 18, color: AppColors.cyanLight),
            ),
          ),
          ScaleTap(
            onTap: () => provider.fetchBookmarks(),
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(Icons.refresh, size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Platform Filter Chips
          if (provider.availablePlatforms.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PlatformFilterRow(
                platforms: provider.availablePlatforms,
                selectedPlatform: provider.selectedPlatform,
                onPlatformSelected: (platform) {
                  provider.setPlatformFilter(platform);
                },
              ),
            ),

          // Main Content
          Expanded(
            child: RefreshIndicator(
              color: AppColors.cyan,
              backgroundColor: AppColors.surface,
              onRefresh: () => provider.fetchBookmarks(),
              child: _buildBody(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BookmarksProvider provider) {
    if (provider.isLoading && provider.bookmarks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.cyan),
            SizedBox(height: 16),
            Text(
              'Retrieving memory graph...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null && provider.bookmarks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => provider.fetchBookmarks(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Retry Connection'),
              ),
            ],
          ),
        ),
      );
    }

    final displayList = provider.filteredBookmarks;

    if (displayList.isEmpty) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.bookmark_border,
                          size: 38,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'No bookmarks stored',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Drop a link from any app or adjust platform filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 4, bottom: 96), // Extra bottom padding for floating nav
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        return StaggeredEntrance(
          index: index,
          child: BookmarkCard(
            bookmark: item,
            onTap: () => _showDetailSheet(item),
            onDelete: () => _confirmDelete(item),
          ),
        );
      },
    );
  }
}
