class ApiConstants {
  // Default development URLs
  // Android Emulator: 10.0.2.2:8000
  // iOS / Web / Local Desktop: 127.0.0.1:8000
  static const String defaultAndroidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String defaultLocalhostUrl = 'http://127.0.0.1:8000';

  // Endpoint paths
  static const String bookmarksEndpoint = '/api/bookmarks';
  static const String searchEndpoint = '/api/search';
  static const String healthEndpoint = '/health';

  // Network timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

