import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/network/api_client.dart';
import 'core/services/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/bookmarks_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dark navigation bar / status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A24),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final preferencesService = PreferencesService();
  final initialBaseUrl = await preferencesService.getBaseUrl();
  final apiClient = ApiClient(baseUrl: initialBaseUrl);

  runApp(
    RecallApp(
      preferencesService: preferencesService,
      apiClient: apiClient,
    ),
  );
}

class RecallApp extends StatelessWidget {
  final PreferencesService preferencesService;
  final ApiClient apiClient;

  const RecallApp({
    super.key,
    required this.preferencesService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(
            preferencesService: preferencesService,
            apiClient: apiClient,
          )..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => BookmarksProvider(
            apiClient: apiClient,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(
            apiClient: apiClient,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Recall',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainNavigationScreen(),
      ),
    );
  }
}
