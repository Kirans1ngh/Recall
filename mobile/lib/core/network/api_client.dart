import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../../models/bookmark.dart';
import '../../models/search_response.dart';
import 'api_exception.dart';

class ApiClient {
  String baseUrl;
  final http.Client _httpClient;

  ApiClient({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  void updateBaseUrl(String newUrl) {
    baseUrl = newUrl.endsWith('/') ? newUrl.substring(0, newUrl.length - 1) : newUrl;
  }

  Uri _buildUri(String path, [Map<String, dynamic>? queryParameters]) {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final urlString = '$cleanBase$path';
    final uri = Uri.parse(urlString);

    if (queryParameters != null && queryParameters.isNotEmpty) {
      final sanitizedParams = <String, String>{};
      queryParameters.forEach((key, value) {
        if (value != null) {
          sanitizedParams[key] = value.toString();
        }
      });
      return uri.replace(queryParameters: sanitizedParams);
    }
    return uri;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<T> _handleRequest<T>(Future<http.Response> Function() request, T Function(dynamic json) parse) async {
    try {
      final response = await request().timeout(ApiConstants.receiveTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return parse(null);
        }
        final dynamic decoded = jsonDecode(utf8.decode(response.bodyBytes));
        return parse(decoded);
      } else if (response.statusCode == 404) {
        throw NotFoundException(message: 'Resource not found: ${response.statusCode}');
      } else {
        throw ServerException(
          message: 'Server responded with status code ${response.statusCode}: ${response.body}',
          statusCode: response.statusCode,
        );
      }
    } on SocketException catch (e) {
      throw NetworkException(message: 'Network unreachable. Please check server URL and connection: ${e.message}');
    } on TimeoutException {
      throw NetworkException(message: 'Request timed out after ${ApiConstants.receiveTimeout.inSeconds} seconds');
    } on FormatException catch (e) {
      throw ApiException(message: 'Invalid response format: ${e.message}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: 'Unexpected error: $e');
    }
  }

  Future<bool> checkHealth() async {
    try {
      final uri = _buildUri(ApiConstants.healthEndpoint);
      final response = await _httpClient.get(uri).timeout(const Duration(seconds: 4));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Bookmark>> getBookmarks({
    String? status,
    String? platform,
    int limit = 50,
    int offset = 0,
  }) async {
    final uri = _buildUri(ApiConstants.bookmarksEndpoint, {
      if (status != null && status.isNotEmpty) 'status': status,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
      'limit': limit,
      'offset': offset,
    });

    return _handleRequest(
      () => _httpClient.get(uri, headers: _headers),
      (data) {
        if (data is List) {
          return data.map((item) => Bookmark.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <Bookmark>[];
      },
    );
  }

  Future<Bookmark> getBookmark(String id) async {
    final uri = _buildUri('${ApiConstants.bookmarksEndpoint}/$id');
    return _handleRequest(
      () => _httpClient.get(uri, headers: _headers),
      (data) => Bookmark.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<Bookmark> createBookmark(String url, {String? notes}) async {
    final uri = _buildUri(ApiConstants.bookmarksEndpoint);
    final payload = jsonEncode({
      'url': url,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    });

    return _handleRequest(
      () => _httpClient.post(uri, headers: _headers, body: payload),
      (data) => Bookmark.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> deleteBookmark(String id) async {
    final uri = _buildUri('${ApiConstants.bookmarksEndpoint}/$id');
    await _handleRequest(
      () => _httpClient.delete(uri, headers: _headers),
      (_) => null,
    );
  }

  Future<SearchResponse> search(
    String query, {
    int limit = 10,
    String? platform,
  }) async {
    final uri = _buildUri(ApiConstants.searchEndpoint, {
      'q': query,
      'limit': limit,
      if (platform != null && platform.isNotEmpty) 'platform': platform,
    });

    return _handleRequest(
      () => _httpClient.get(uri, headers: _headers),
      (data) => SearchResponse.fromJson(data as Map<String, dynamic>),
    );
  }

  void dispose() {
    _httpClient.close();
  }
}

