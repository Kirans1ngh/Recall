import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/scale_tap.dart';
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
            content: Text('Bookmark ingested. Neural extraction started in background.'),
            backgroundColor: AppColors.success,
          ),
        );
      }

      await Future.delayed(const Duration(milliseconds: 900));
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
            content: Text('Failed to ingest bookmark: $e'),
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
            Text('Ingest Content'),
            Text(
              'Input any web, video, or social link for automated synthesis',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 100), // Extra bottom padding for floating nav
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL input field
              const Text(
                'Source URL',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
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
                  prefixIcon: const Icon(Icons.link, color: AppColors.cyanLight, size: 20),
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
                      ScaleTap(
                        onTap: _pasteFromClipboard,
                        scaleDown: 0.90,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceLight,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.content_paste, size: 16, color: AppColors.cyanLight),
                        ),
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

              // Personal Context
              const Text(
                'Context & Retrieval Notes (optional)',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                style: const TextStyle(color: AppColors.text, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Why are you saving this? Key thoughts or future recall triggers...',
                ),
              ),
              const SizedBox(height: 28),

              // Save button with spring animation
              ScaleTap(
                scaleDown: 0.96,
                onTap: isSubmitting ? null : _submit,
                child: Container(
                  width: double.infinity,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: _isSuccess
                        ? const LinearGradient(colors: [AppColors.success, Color(0xFF059669)])
                        : AppColors.aiSynthesisGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSuccess ? AppColors.success : AppColors.primary).withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Center(
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
                                  Text(
                                    'Ingested Successfully',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.bolt, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Ingest & Synthesize',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.2,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Cognitive Tip Card
              GlassContainer(
                borderRadius: 16,
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.lightbulb_outline, size: 20, color: AppColors.cyanLight),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seamless Share Target',
                            style: TextStyle(
                              color: AppColors.text,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'You can also share links directly from YouTube, Twitter/X, or browsers using the device share sheet.',
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
                'Supported Integrations',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildPlatformChip('YouTube', AppColors.youtube),
                  _buildPlatformChip('Twitter / X', AppColors.twitter),
                  _buildPlatformChip('Instagram', AppColors.instagram),
                  _buildPlatformChip('Spotify', AppColors.spotify),
                  _buildPlatformChip('Reddit', AppColors.reddit),
                  _buildPlatformChip('GitHub', AppColors.github),
                  _buildPlatformChip('Websites & Blogs', AppColors.webpage),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
