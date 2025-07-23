import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'core/constants/app_constants.dart';
import 'core/themes/app_themes.dart';
import 'core/router/app_router.dart';
import 'core/providers/app_providers.dart';
import 'core/services/termux_service.dart';
import 'core/services/ai_service.dart';
import 'core/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize system settings
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  // Enable wakelock for terminal sessions
  WakelockPlus.enable();
  
  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Initialize core services
  await _initializeApp();
  
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const ROSApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    // Request permissions
    await PermissionService.requestInitialPermissions();
    
    // Initialize Termux environment
    await TermuxService.initialize();
    
    // Initialize AI service
    await AIService.initialize();
    
  } catch (e) {
    debugPrint('App initialization error: $e');
  }
}

class ROSApp extends ConsumerWidget {
  const ROSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final colorScheme = ref.watch(colorSchemeProvider);
    
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      
      // Theme Configuration
      theme: AppThemes.lightTheme(colorScheme),
      darkTheme: AppThemes.darkTheme(colorScheme),
      themeMode: themeMode,
      
      // Router Configuration
      routerConfig: AppRouter.router,
      
      // App Configuration
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}