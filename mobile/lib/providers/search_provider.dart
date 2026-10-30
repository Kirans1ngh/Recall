import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/search_response.dart';
import '../models/search_result.dart';

class SearchProvider extends ChangeNotifier {
  final ApiClient apiClient;

  String _query = '';
  SearchResponse? _response;
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  final List<String> _sampleQueries = const [
    'What was that video about AI tools?',
    'Articles about machine learning and transformers',
    'Song recommendations from Spotify',
    'Tweets and posts about Python async',
    'System design and database optimization',
  ];

  SearchProvider({required this.apiClient});

  String get query => _query;
  SearchResponse? get response => _response;
  List<SearchResult> get results => _response?.results ?? [];
  String? get answer => _response?.answer;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;
  String? get errorMessage => _errorMessage;
  List<String> get sampleQueries => _sampleQueries;

  Future<void> search(String searchQuery, {String? platform}) async {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) return;

    _query = trimmed;
    _isLoading = true;
    _hasSearched = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.search(trimmed, platform: platform);
      _response = res;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _response = null;
    } catch (e) {
      _errorMessage = 'Search failed: $e';
      _response = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _query = '';
    _response = null;
    _hasSearched = false;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
}
