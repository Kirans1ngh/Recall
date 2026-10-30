class SearchResult {
  final String bookmarkId;
  final String url;
  final String? title;
  final String? summary;
  final double relevanceScore;
  final String? matchedContent;

  const SearchResult({
    required this.bookmarkId,
    required this.url,
    this.title,
    this.summary,
    required this.relevanceScore,
    this.matchedContent,
  });

  int get scorePercentage => (relevanceScore * 100).clamp(0, 100).round();

  String get displayTitle => (title != null && title!.trim().isNotEmpty) ? title! : url;

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final rawScore = json['relevance_score'];
    double score = 0.0;
    if (rawScore is num) {
      score = rawScore.toDouble();
    } else if (rawScore is String) {
      score = double.tryParse(rawScore) ?? 0.0;
    }

    return SearchResult(
      bookmarkId: json['bookmark_id'] as String? ?? '',
      url: json['url'] as String? ?? '',
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      relevanceScore: score,
      matchedContent: json['matched_content'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookmark_id': bookmarkId,
      'url': url,
      'title': title,
      'summary': summary,
      'relevance_score': relevanceScore,
      'matched_content': matchedContent,
    };
  }
}

