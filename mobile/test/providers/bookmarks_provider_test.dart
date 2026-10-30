import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recall_mobile/core/network/api_client.dart';
import 'package:recall_mobile/providers/bookmarks_provider.dart';

void main() {
  group('BookmarksProvider Tests', () {
    test('fetchBookmarks loads and filters bookmarks by platform', () async {
      final mockData = [
        {
          'id': 'b1',
          'url': 'https://youtube.com/watch?v=1',
          'platform': 'youtube',
          'title': 'Flutter 3.47 Tutorial',
          'status': 'completed',
          'created_at': '2026-10-30T10:00:00Z',
        },
        {
          'id': 'b2',
          'url': 'https://twitter.com/x/status/2',
          'platform': 'twitter',
          'title': 'Tech Release',
          'status': 'completed',
          'created_at': '2026-10-30T11:00:00Z',
        },
      ];

      final client = MockClient((request) async {
        if (request.url.path == '/api/bookmarks') {
          return http.Response(jsonEncode(mockData), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8000', httpClient: client);
      final provider = BookmarksProvider(apiClient: apiClient);

      await provider.fetchBookmarks();

      expect(provider.isLoading, isFalse);
      expect(provider.bookmarks.length, 2);
      expect(provider.availablePlatforms, ['twitter', 'youtube']);

      // Filter by platform 'youtube'
      provider.setPlatformFilter('youtube');
      expect(provider.selectedPlatform, 'youtube');
      expect(provider.filteredBookmarks.length, 1);
      expect(provider.filteredBookmarks.first.platform, 'youtube');

      // Clear filter by toggling again
      provider.setPlatformFilter('youtube');
      expect(provider.selectedPlatform, isNull);
      expect(provider.filteredBookmarks.length, 2);
    });

    test('createBookmark prepends new bookmark to the list', () async {
      final newBookmarkJson = {
        'id': 'b3',
        'url': 'https://example.com/new',
        'platform': 'webpage',
        'title': 'New Webpage',
        'status': 'pending',
        'created_at': '2026-10-30T12:00:00Z',
      };

      final client = MockClient((request) async {
        if (request.method == 'POST' && request.url.path == '/api/bookmarks') {
          return http.Response(jsonEncode(newBookmarkJson), 200);
        }
        return http.Response('Not Found', 404);
      });

      final apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8000', httpClient: client);
      final provider = BookmarksProvider(apiClient: apiClient);

      final result = await provider.createBookmark('https://example.com/new');

      expect(result.id, 'b3');
      expect(provider.bookmarks.length, 1);
      expect(provider.bookmarks.first.url, 'https://example.com/new');
      expect(provider.isSubmitting, isFalse);
    });
  });
}

