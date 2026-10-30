import 'package:flutter_test/flutter_test.dart';
import 'package:recall_mobile/models/search_response.dart';
import 'package:recall_mobile/models/search_result.dart';

void main() {
  group('Search Models Tests', () {
    test('SearchResult parses correctly and computes score percentage', () {
      final json = {
        'bookmark_id': 'bm_1',
        'url': 'https://example.com/ml-guide',
        'title': 'Machine Learning Guide',
        'summary': 'Intro to ML models.',
        'relevance_score': 0.875,
      };

      final result = SearchResult.fromJson(json);

      expect(result.bookmarkId, 'bm_1');
      expect(result.url, 'https://example.com/ml-guide');
      expect(result.title, 'Machine Learning Guide');
      expect(result.scorePercentage, 88);
      expect(result.displayTitle, 'Machine Learning Guide');
    });

    test('SearchResponse parses list of results and AI answer', () {
      final json = {
        'query': 'transformer attention',
        'results': [
          {
            'bookmark_id': 'bm_1',
            'url': 'https://arxiv.org/abs/1706.03762',
            'title': 'Attention Is All You Need',
            'summary': 'Paper introducing Transformer architecture.',
            'relevance_score': 0.96,
          }
        ],
        'total': 1,
        'answer': 'The Transformer uses self-attention mechanisms to process sequence data.',
      };

      final response = SearchResponse.fromJson(json);

      expect(response.query, 'transformer attention');
      expect(response.total, 1);
      expect(response.results.length, 1);
      expect(response.results.first.scorePercentage, 96);
      expect(response.answer, contains('self-attention'));
    });
  });
}

