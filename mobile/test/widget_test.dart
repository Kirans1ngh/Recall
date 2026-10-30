import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:recall_mobile/core/network/api_client.dart';
import 'package:recall_mobile/core/services/preferences_service.dart';
import 'package:recall_mobile/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('RecallApp loads with bottom navigation and default tabs', (WidgetTester tester) async {
    // Mock HTTP client returning empty bookmarks list and healthy status
    final mockClient = MockClient((request) async {
      if (request.url.path == '/health') {
        return http.Response(jsonEncode({'status': 'healthy'}), 200);
      }
      if (request.url.path == '/api/bookmarks') {
        return http.Response(jsonEncode([]), 200);
      }
      return http.Response('Not Found', 404);
    });

    final preferencesService = PreferencesService();
    final apiClient = ApiClient(baseUrl: 'http://127.0.0.1:8000', httpClient: mockClient);

    await tester.pumpWidget(
      RecallApp(
        preferencesService: preferencesService,
        apiClient: apiClient,
      ),
    );

    // Initial load
    await tester.pumpAndSettle();

    // Verify Bottom Navigation Bar tabs exist
    expect(find.text('Bookmarks'), findsWidgets);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);

    // Verify empty state text on home screen
    expect(find.text('No bookmarks found'), findsOneWidget);

    // Tap Search Tab
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    // Verify Search Screen elements
    expect(find.text('Semantic Search'), findsOneWidget);
    expect(find.text('Try asking:'), findsOneWidget);
    expect(find.text('What was that video about AI tools?'), findsWidgets);

    // Tap Add Tab
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    // Verify Add Bookmark Screen elements
    expect(find.text('Add Bookmark'), findsOneWidget);
    expect(find.text('Paste a URL to save and analyze'), findsOneWidget);
    expect(find.text('Save & Process Bookmark'), findsOneWidget);

    // Test form validation on empty submit
    await tester.tap(find.text('Save & Process Bookmark'));
    await tester.pumpAndSettle();
    expect(find.text('Please enter a URL'), findsOneWidget);
  });
}
