import 'search_result.dart';

class SearchResponse {
  final String query;
  final List<SearchResult> results;
  final int total;
  final String? answer;

  const SearchResponse({
    required this.query,
    required this.results,
    required this.total,
    this.answer,
  });

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    final rawResults = json['results'] as List<dynamic>? ?? [];
    final parsedResults = rawResults
        .map((e) => SearchResult.fromJson(e as Map<String, dynamic>))
        .toList();

    return SearchResponse(
      query: json['query'] as String? ?? '',
      results: parsedResults,
      total: json['total'] as int? ?? parsedResults.length,
      answer: json['answer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'results': results.map((r) => r.toJson()).toList(),
      'total': total,
      'answer': answer,
    };
  }
}

