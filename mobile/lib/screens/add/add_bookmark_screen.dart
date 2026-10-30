import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/bookmarks_provider.dart';

class AddBookmarkScreen extends StatefulWidget {
  final VoidCallback? onBookmarkAdded;

  const AddBookmarkScreen({super.key, this.onBookmarkAdded});

  @override
  State<AddBookmarkScreen> createState() => _AddBookmarkScreenState();
}

class _AddBookmarkScreenState extends State<AddBookmarkScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSuccess = false;

  @override
  void dispose() {
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.trim().isNotEmpty) {
      setState(() {
        _urlController.text = data.text!.trim();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final url = _urlController.text.trim();
    final notes = _notesController.text.trim();

    FocusScope.of(context).unfocus();

    try {
      await context.read<BookmarksProvider>().createBookmark(
            url,
            notes: notes.isNotEmpty ? notes : null,
          );

      setState(() {
        _isSuccess = true;
      });

      _urlController.clear();
      _notesController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark saved! Content is being analyzed in the background.'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _isSuccess = false;
        });
        widget.onBookmarkAdded?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save bookmark: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BookmarksProvider>();
    final isSubmitting = provider.isSubmitting;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Bookmark'),
            Text(
              'Paste a URL to save and analyze',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL input field
              const Text(
                'URL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _urlController,
                keyboardType: TextInputType.url,
                autocorrect: false,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'https://youtube.com/watch?v=... or article link',
                  prefixIcon: const Icon(Icons.link, color: AppColors.primaryLight, size: 20),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_urlController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                          onPressed: () {
                            _urlController.clear();
                            setState(() {});
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.content_paste, size: 18, color: AppColors.primaryLight),
                        tooltip: 'Paste from clipboard',
                        onPressed: _pasteFromClipboard,
                      ),
                    ],
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a URL';
                  }
                  final uri = Uri.tryParse(value.trim());
                  if (uri == null || !uri.hasScheme || (uri.scheme != 'http' && uri.scheme != 'https')) {
                    return 'Please enter a valid URL starting with http:// or https://';
                  }
                  return null;
                },
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // Notes input field
              const Text(
                'Personal Notes (optional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Why are you saving this? Any specific takeaway or context...',
                ),
              ),
              const SizedBox(height: 28),

              // Save button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSuccess ? AppColors.success : AppColors.primary,
                  ),
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : _isSuccess
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Saved! Analyzing...'),
                              ],
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.bookmark_add, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text('Save & Process Bookmark'),
                              ],
                            ),
                ),
              ),
              const SizedBox(height: 28),

              // Share Intent Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLight),
                ),
                child: const Row(
                  children: [
                    Text('💡', style: TextStyle(fontSize: 24)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Tip',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'You can also share links directly from YouTube, Twitter, or Safari/Chrome via the system share sheet.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Supported Platforms List
              const Text(
                'Supported Platforms',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPlatformChip('📺 YouTube', AppColors.youtube),
                  _buildPlatformChip('🐦 Twitter / X', AppColors.twitter),
                  _buildPlatformChip('📷 Instagram', AppColors.instagram),
                  _buildPlatformChip('🎵 Spotify', AppColors.spotify),
                  _buildPlatformChip('🔴 Reddit', AppColors.reddit),
                  _buildPlatformChip('💻 GitHub', AppColors.github),
                  _buildPlatformChip('🌐 Websites & Blogs', AppColors.webpage),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlatformChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

