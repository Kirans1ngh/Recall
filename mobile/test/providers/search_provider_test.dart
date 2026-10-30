import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recall_mobile/core/network/api_client.dart';
import 'package:recall_mobile/providers/search_provider.dart';

void main() {
  group('SearchProvider Tests', () {
    test('search updates state with response results and answer', () async {
      final mockResponse = {
        'query': 'machine learning',
        'results': [
          {
            'bookmark_id': 'b1',
            'url': 'https://ml.org/intro',
            'title': 'Machine Learning 101',
            'summary': 'Basics of ML.',
            'relevance_score': 0.92,
          }
        ],
        'total': 1,
        'answer': 'Here are the key takeaways for Machine Learning 101.',
      };

      final client = MockClient((request) async {
        if (request.url.path == '/api/search') {
          return http.Response(jsonEncode(mockResponse), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8000', httpClient: client);
      final provider = SearchProvider(apiClient: apiClient);

      expect(provider.hasSearched, isFalse);

      await provider.search('machine learning');

      expect(provider.isLoading, isFalse);
      expect(provider.hasSearched, isTrue);
      expect(provider.results.length, 1);
      expect(provider.answer, 'Here are the key takeaways for Machine Learning 101.');
      expect(provider.results.first.displayTitle, 'Machine Learning 101');

      // Test clear
      provider.clear();
      expect(provider.hasSearched, isFalse);
      expect(provider.results, isEmpty);
      expect(provider.answer, isNull);
    });
  });
}

