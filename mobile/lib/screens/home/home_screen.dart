import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Bookmark', style: TextStyle(color: AppColors.text, fontSize: 18)),
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
              '${provider.totalBookmarksCount} saved',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: AppColors.textSecondary),
            tooltip: 'Server Settings',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => const ServerSettingsDialog(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: () => provider.fetchBookmarks(),
          ),
          const SizedBox(width: 8),
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
              color: AppColors.primary,
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
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading bookmarks...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('📎', style: TextStyle(fontSize: 56)),
                      SizedBox(height: 16),
                      Text(
                        'No bookmarks found',
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Save your first link or adjust your active platform filters',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
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
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final item = displayList[index];
        return BookmarkCard(
          bookmark: item,
          onTap: () => _showDetailSheet(item),
          onDelete: () => _confirmDelete(item),
        );
      },
    );
  }
}
