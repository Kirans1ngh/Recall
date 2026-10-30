import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class PreferencesService {
  static const String _keyApiBaseUrl = 'api_base_url';

  static String getDefaultBaseUrl() {
    if (kIsWeb) {
      return ApiConstants.defaultLocalhostUrl;
    }
    // Android emulator check or default
    return defaultTargetPlatform == TargetPlatform.android
        ? ApiConstants.defaultAndroidEmulatorUrl
        : ApiConstants.defaultLocalhostUrl;
  }

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyApiBaseUrl) ?? getDefaultBaseUrl();
  }

  Future<void> setBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyApiBaseUrl, url);
  }

  Future<void> resetBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyApiBaseUrl);
  }
}

