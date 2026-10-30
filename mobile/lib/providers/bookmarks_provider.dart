import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../models/bookmark.dart';

class BookmarksProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<Bookmark> _bookmarks = [];
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _selectedPlatform;
  String? _selectedStatus;
  Timer? _pollingTimer;

  BookmarksProvider({required this.apiClient});

  List<Bookmark> get bookmarks => _bookmarks;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get selectedPlatform => _selectedPlatform;
  String? get selectedStatus => _selectedStatus;

  List<Bookmark> get filteredBookmarks {
    return _bookmarks.where((b) {
      if (_selectedPlatform != null && _selectedPlatform!.isNotEmpty) {
        if (b.platform.toLowerCase() != _selectedPlatform!.toLowerCase()) {
          return false;
        }
      }
      if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
        if (b.status.toLowerCase() != _selectedStatus!.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  int get totalBookmarksCount => _bookmarks.length;

  List<String> get availablePlatforms {
    final set = <String>{};
    for (final b in _bookmarks) {
      set.add(b.platform.toLowerCase());
    }
    return set.toList()..sort();
  }

  Future<void> fetchBookmarks({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final items = await apiClient.getBookmarks(
        status: _selectedStatus,
        platform: _selectedPlatform,
      );
      _bookmarks = items;
      _errorMessage = null;

      _checkAndSchedulePolling();
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load bookmarks: $e';
    } finally {
      if (!silent) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  void _checkAndSchedulePolling() {
    final hasProcessing = _bookmarks.any((b) => b.isProcessing || b.isPending);
    _pollingTimer?.cancel();

    if (hasProcessing) {
      _pollingTimer = Timer(const Duration(seconds: 4), () {
        fetchBookmarks(silent: true);
      });
    }
  }

  Future<Bookmark> createBookmark(String url, {String? notes}) async {
    _isSubmitting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final created = await apiClient.createBookmark(url, notes: notes);
      // Prepend to current list for instant feedback
      _bookmarks.insert(0, created);
      _checkAndSchedulePolling();
      return created;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      rethrow;
    } catch (e) {
      _errorMessage = 'Failed to create bookmark: $e';
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  Future<void> deleteBookmark(String id) async {
    final previousList = List<Bookmark>.from(_bookmarks);
    _bookmarks.removeWhere((b) => b.id == id);
    notifyListeners();

    try {
      await apiClient.deleteBookmark(id);
    } catch (e) {
      // Revert if API call fails
      _bookmarks = previousList;
      _errorMessage = 'Failed to delete bookmark: $e';
      notifyListeners();
      rethrow;
    }
  }

  void setPlatformFilter(String? platform) {
    if (_selectedPlatform == platform) {
      _selectedPlatform = null;
    } else {
      _selectedPlatform = platform;
    }
    notifyListeners();
    fetchBookmarks();
  }

  void setStatusFilter(String? status) {
    if (_selectedStatus == status) {
      _selectedStatus = null;
    } else {
      _selectedStatus = status;
    }
    notifyListeners();
    fetchBookmarks();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }
}
