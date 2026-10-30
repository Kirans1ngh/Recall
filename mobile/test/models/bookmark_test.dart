import 'package:flutter_test/flutter_test.dart';
import 'package:recall_mobile/models/bookmark.dart';

void main() {
  group('Bookmark Model Tests', () {
    test('Correctly deserializes JSON with complete fields', () {
      final json = {
        'id': 'b123',
        'url': 'https://youtube.com/watch?v=dQw4w9WgXcQ',
        'platform': 'youtube',
        'title': 'Never Gonna Give You Up',
        'summary': 'Iconic 80s music video by Rick Astley.',
        'key_points': ['Classic hit', 'Memetic video'],
        'tags': ['music', 'retro', 'pop'],
        'status': 'completed',
        'created_at': '2026-10-30T10:00:00.000Z',
        'processed_at': '2026-10-30T10:00:05.000Z',
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, 'b123');
      expect(bookmark.url, 'https://youtube.com/watch?v=dQw4w9WgXcQ');
      expect(bookmark.platform, 'youtube');
      expect(bookmark.title, 'Never Gonna Give You Up');
      expect(bookmark.summary, 'Iconic 80s music video by Rick Astley.');
      expect(bookmark.keyPoints.length, 2);
      expect(bookmark.tags.length, 3);
      expect(bookmark.isCompleted, isTrue);
      expect(bookmark.isProcessing, isFalse);
      expect(bookmark.platformEmoji, '📺');
    });

    test('Handles missing / null fields gracefully', () {
      final json = {
        'id': 'b456',
        'url': 'https://example.com/article',
        'status': 'pending',
      };

      final bookmark = Bookmark.fromJson(json);

      expect(bookmark.id, 'b456');
      expect(bookmark.platform, 'webpage');
      expect(bookmark.title, isNull);
      expect(bookmark.summary, isNull);
      expect(bookmark.keyPoints, isEmpty);
      expect(bookmark.tags, isEmpty);
      expect(bookmark.isPending, isTrue);
      expect(bookmark.displayTitle, 'Analyzing bookmark content...');
      expect(bookmark.platformEmoji, '🌐');
    });

    test('Serializes to JSON correctly', () {
      final now = DateTime.utc(2026, 10, 30, 12, 0);
      final bookmark = Bookmark(
        id: 'b789',
        url: 'https://twitter.com/x/status/1',
        platform: 'twitter',
        title: 'Tech Announcement',
        status: 'processing',
        createdAt: now,
      );

      final json = bookmark.toJson();

      expect(json['id'], 'b789');
      expect(json['platform'], 'twitter');
      expect(json['status'], 'processing');
      expect(json['created_at'], now.toIso8601String());
    });
  });
}

