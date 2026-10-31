import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/scale_tap.dart';
import '../../core/widgets/staggered_entrance.dart';
import '../../providers/search_provider.dart';
import 'widgets/ai_answer_card.dart';
import 'widgets/query_suggestions.dart';
import 'widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _executeSearch(String query) {
    if (query.trim().isEmpty) return;
    _focusNode.unfocus();
    context.read<SearchProvider>().search(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SearchProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Semantic Recall'),
            Text(
              'Query semantic embeddings and synthesized insights',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    textInputAction: TextInputAction.search,
                    onSubmitted: _executeSearch,
                    style: const TextStyle(color: AppColors.text, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'What was that video about AI tools?',
                      prefixIcon: const Icon(Icons.search, color: AppColors.cyanLight, size: 20),
                      suffixIcon: _controller.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.textMuted),
                              onPressed: () {
                                _controller.clear();
                                provider.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                ScaleTap(
                  scaleDown: 0.90,
                  onTap: _controller.text.trim().isNotEmpty && !provider.isLoading
                      ? () => _executeSearch(_controller.text)
                      : null,
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      gradient: _controller.text.trim().isNotEmpty && !provider.isLoading
                          ? AppColors.aiSynthesisGradient
                          : null,
                      color: _controller.text.trim().isEmpty || provider.isLoading
                          ? AppColors.surfaceLight
                          : null,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _controller.text.trim().isNotEmpty && !provider.isLoading
                            ? AppColors.primaryLight.withValues(alpha: 0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Center(
                      child: provider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.cyanLight),
                            )
                          : const Icon(Icons.arrow_forward, size: 20, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Search Content
          Expanded(
            child: _buildBody(provider),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(SearchProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.cyan),
            SizedBox(height: 16),
            Text(
              'Traversing neural index & synthesizing answer...',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _executeSearch(_controller.text),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (!provider.hasSearched) {
      return SingleChildScrollView(
        padding: const EdgeInsets.only(top: 8, bottom: 96),
        child: QuerySuggestions(
          suggestions: provider.sampleQueries,
          onSelected: (selected) {
            _controller.text = selected;
            setState(() {});
            _executeSearch(selected);
          },
        ),
      );
    }

    if (provider.results.isEmpty && (provider.answer == null || provider.answer!.isEmpty)) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.manage_search, size: 52, color: AppColors.textMuted),
              SizedBox(height: 16),
              Text(
                'No semantic matches',
                style: TextStyle(color: AppColors.text, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Try asking with different concepts or add more bookmarks first',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 96), // Extra bottom padding for floating nav
      children: [
        if (provider.answer != null && provider.answer!.trim().isNotEmpty)
          AiAnswerCard(answer: provider.answer!),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            '${provider.results.length} Indexed Match${provider.results.length == 1 ? '' : 'es'}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
        ),
        ...provider.results.asMap().entries.map((entry) {
          final index = entry.key;
          final result = entry.value;
          return StaggeredEntrance(
            index: index,
            child: SearchResultCard(result: result),
          );
        }),
      ],
    );
  }
}
