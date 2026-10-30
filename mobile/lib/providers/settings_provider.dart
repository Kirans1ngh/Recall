import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/services/preferences_service.dart';

class SettingsProvider extends ChangeNotifier {
  final PreferencesService preferencesService;
  final ApiClient apiClient;

  String _baseUrl = '';
  bool _isChecking = false;
  bool? _isServerReachable;

  SettingsProvider({
    required this.preferencesService,
    required this.apiClient,
  });

  String get baseUrl => _baseUrl;
  bool get isChecking => _isChecking;
  bool? get isServerReachable => _isServerReachable;

  Future<void> initialize() async {
    _baseUrl = await preferencesService.getBaseUrl();
    apiClient.updateBaseUrl(_baseUrl);
    notifyListeners();
    await testConnection();
  }

  Future<void> updateBaseUrl(String newUrl) async {
    _baseUrl = newUrl.trim();
    await preferencesService.setBaseUrl(_baseUrl);
    apiClient.updateBaseUrl(_baseUrl);
    notifyListeners();
    await testConnection();
  }

  Future<void> resetToDefault() async {
    await preferencesService.resetBaseUrl();
    _baseUrl = PreferencesService.getDefaultBaseUrl();
    apiClient.updateBaseUrl(_baseUrl);
    notifyListeners();
    await testConnection();
  }

  Future<bool> testConnection() async {
    _isChecking = true;
    notifyListeners();

    try {
      final healthy = await apiClient.checkHealth();
      _isServerReachable = healthy;
      return healthy;
    } catch (_) {
      _isServerReachable = false;
      return false;
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }
}
