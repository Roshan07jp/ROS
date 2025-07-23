import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../themes/app_themes.dart';
import '../constants/app_constants.dart';

// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

// Theme Mode Provider
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ThemeModeNotifier(prefs);
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const String _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(_getInitialThemeMode(_prefs));

  static ThemeMode _getInitialThemeMode(SharedPreferences prefs) {
    final savedMode = prefs.getString(_key);
    switch (savedMode) {
      case AppThemes.lightMode:
        return ThemeMode.light;
      case AppThemes.darkMode:
        return ThemeMode.dark;
      case AppThemes.systemMode:
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = AppThemes.lightMode;
        break;
      case ThemeMode.dark:
        modeString = AppThemes.darkMode;
        break;
      case ThemeMode.system:
        modeString = AppThemes.systemMode;
        break;
    }
    await _prefs.setString(_key, modeString);
  }
}

// Color Scheme Provider
final colorSchemeProvider = StateNotifierProvider<ColorSchemeNotifier, String>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return ColorSchemeNotifier(prefs);
});

class ColorSchemeNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  static const String _key = 'color_scheme';

  ColorSchemeNotifier(this._prefs) : super(_prefs.getString(_key) ?? AppThemes.hackerGreen);

  Future<void> setColorScheme(String scheme) async {
    state = scheme;
    await _prefs.setString(_key, scheme);
  }
}

// Terminal Settings Provider
final terminalSettingsProvider = StateNotifierProvider<TerminalSettingsNotifier, TerminalSettings>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return TerminalSettingsNotifier(prefs);
});

class TerminalSettingsNotifier extends StateNotifier<TerminalSettings> {
  final SharedPreferences _prefs;

  TerminalSettingsNotifier(this._prefs) : super(TerminalSettings.fromPrefs(_prefs));

  Future<void> updateFontFamily(String fontFamily) async {
    state = state.copyWith(fontFamily: fontFamily);
    await _prefs.setString('terminal_font_family', fontFamily);
  }

  Future<void> updateFontSize(double fontSize) async {
    state = state.copyWith(fontSize: fontSize);
    await _prefs.setDouble('terminal_font_size', fontSize);
  }

  Future<void> updateColorScheme(String colorScheme) async {
    state = state.copyWith(terminalColorScheme: colorScheme);
    await _prefs.setString('terminal_color_scheme', colorScheme);
  }

  Future<void> updateOpacity(double opacity) async {
    state = state.copyWith(opacity: opacity);
    await _prefs.setDouble('terminal_opacity', opacity);
  }

  Future<void> updateCursorBlink(bool blink) async {
    state = state.copyWith(cursorBlink: blink);
    await _prefs.setBool('terminal_cursor_blink', blink);
  }

  Future<void> updateShell(String shell) async {
    state = state.copyWith(shell: shell);
    await _prefs.setString('terminal_shell', shell);
  }
}

class TerminalSettings {
  final String fontFamily;
  final double fontSize;
  final String terminalColorScheme;
  final double opacity;
  final bool cursorBlink;
  final String shell;
  final int maxSessions;
  final int historySize;

  const TerminalSettings({
    required this.fontFamily,
    required this.fontSize,
    required this.terminalColorScheme,
    required this.opacity,
    required this.cursorBlink,
    required this.shell,
    required this.maxSessions,
    required this.historySize,
  });

  factory TerminalSettings.fromPrefs(SharedPreferences prefs) {
    return TerminalSettings(
      fontFamily: prefs.getString('terminal_font_family') ?? AppConstants.defaultTerminalFont,
      fontSize: prefs.getDouble('terminal_font_size') ?? AppConstants.defaultFontSize,
      terminalColorScheme: prefs.getString('terminal_color_scheme') ?? AppThemes.hackerGreen,
      opacity: prefs.getDouble('terminal_opacity') ?? 0.95,
      cursorBlink: prefs.getBool('terminal_cursor_blink') ?? true,
      shell: prefs.getString('terminal_shell') ?? AppConstants.defaultShell,
      maxSessions: prefs.getInt('terminal_max_sessions') ?? AppConstants.maxTerminalSessions,
      historySize: prefs.getInt('terminal_history_size') ?? AppConstants.terminalHistorySize,
    );
  }

  TerminalSettings copyWith({
    String? fontFamily,
    double? fontSize,
    String? terminalColorScheme,
    double? opacity,
    bool? cursorBlink,
    String? shell,
    int? maxSessions,
    int? historySize,
  }) {
    return TerminalSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      terminalColorScheme: terminalColorScheme ?? this.terminalColorScheme,
      opacity: opacity ?? this.opacity,
      cursorBlink: cursorBlink ?? this.cursorBlink,
      shell: shell ?? this.shell,
      maxSessions: maxSessions ?? this.maxSessions,
      historySize: historySize ?? this.historySize,
    );
  }
}

// AI Settings Provider
final aiSettingsProvider = StateNotifierProvider<AISettingsNotifier, AISettings>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AISettingsNotifier(prefs);
});

class AISettingsNotifier extends StateNotifier<AISettings> {
  final SharedPreferences _prefs;

  AISettingsNotifier(this._prefs) : super(AISettings.fromPrefs(_prefs));

  Future<void> updateEnabled(bool enabled) async {
    state = state.copyWith(enabled: enabled);
    await _prefs.setBool('ai_enabled', enabled);
  }

  Future<void> updateApiKey(String apiKey) async {
    state = state.copyWith(apiKey: apiKey);
    await _prefs.setString('ai_api_key', apiKey);
  }

  Future<void> updateModel(String model) async {
    state = state.copyWith(model: model);
    await _prefs.setString('ai_model', model);
  }

  Future<void> updateAutoComplete(bool autoComplete) async {
    state = state.copyWith(autoComplete: autoComplete);
    await _prefs.setBool('ai_auto_complete', autoComplete);
  }

  Future<void> updateSuggestions(bool suggestions) async {
    state = state.copyWith(suggestions: suggestions);
    await _prefs.setBool('ai_suggestions', suggestions);
  }
}

class AISettings {
  final bool enabled;
  final String? apiKey;
  final String model;
  final bool autoComplete;
  final bool suggestions;
  final int maxTokens;
  final double temperature;

  const AISettings({
    required this.enabled,
    this.apiKey,
    required this.model,
    required this.autoComplete,
    required this.suggestions,
    required this.maxTokens,
    required this.temperature,
  });

  factory AISettings.fromPrefs(SharedPreferences prefs) {
    return AISettings(
      enabled: prefs.getBool('ai_enabled') ?? AppConstants.enableAI,
      apiKey: prefs.getString('ai_api_key'),
      model: prefs.getString('ai_model') ?? 'gpt-3.5-turbo',
      autoComplete: prefs.getBool('ai_auto_complete') ?? true,
      suggestions: prefs.getBool('ai_suggestions') ?? true,
      maxTokens: prefs.getInt('ai_max_tokens') ?? 1000,
      temperature: prefs.getDouble('ai_temperature') ?? 0.7,
    );
  }

  AISettings copyWith({
    bool? enabled,
    String? apiKey,
    String? model,
    bool? autoComplete,
    bool? suggestions,
    int? maxTokens,
    double? temperature,
  }) {
    return AISettings(
      enabled: enabled ?? this.enabled,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      autoComplete: autoComplete ?? this.autoComplete,
      suggestions: suggestions ?? this.suggestions,
      maxTokens: maxTokens ?? this.maxTokens,
      temperature: temperature ?? this.temperature,
    );
  }
}

// App Settings Provider
final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return AppSettingsNotifier(prefs);
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SharedPreferences _prefs;

  AppSettingsNotifier(this._prefs) : super(AppSettings.fromPrefs(_prefs));

  Future<void> updateFirstLaunch(bool firstLaunch) async {
    state = state.copyWith(firstLaunch: firstLaunch);
    await _prefs.setBool('first_launch', firstLaunch);
  }

  Future<void> updateBiometricAuth(bool enabled) async {
    state = state.copyWith(biometricAuth: enabled);
    await _prefs.setBool('biometric_auth', enabled);
  }

  Future<void> updateNotifications(bool enabled) async {
    state = state.copyWith(notifications: enabled);
    await _prefs.setBool('notifications', enabled);
  }

  Future<void> updateAutoBackup(bool enabled) async {
    state = state.copyWith(autoBackup: enabled);
    await _prefs.setBool('auto_backup', enabled);
  }

  Future<void> updateAnalytics(bool enabled) async {
    state = state.copyWith(analytics: enabled);
    await _prefs.setBool('analytics', enabled);
  }
}

class AppSettings {
  final bool firstLaunch;
  final bool biometricAuth;
  final bool notifications;
  final bool autoBackup;
  final bool analytics;
  final String language;
  final bool keepScreenOn;

  const AppSettings({
    required this.firstLaunch,
    required this.biometricAuth,
    required this.notifications,
    required this.autoBackup,
    required this.analytics,
    required this.language,
    required this.keepScreenOn,
  });

  factory AppSettings.fromPrefs(SharedPreferences prefs) {
    return AppSettings(
      firstLaunch: prefs.getBool('first_launch') ?? true,
      biometricAuth: prefs.getBool('biometric_auth') ?? false,
      notifications: prefs.getBool('notifications') ?? true,
      autoBackup: prefs.getBool('auto_backup') ?? false,
      analytics: prefs.getBool('analytics') ?? false,
      language: prefs.getString('language') ?? 'en',
      keepScreenOn: prefs.getBool('keep_screen_on') ?? false,
    );
  }

  AppSettings copyWith({
    bool? firstLaunch,
    bool? biometricAuth,
    bool? notifications,
    bool? autoBackup,
    bool? analytics,
    String? language,
    bool? keepScreenOn,
  }) {
    return AppSettings(
      firstLaunch: firstLaunch ?? this.firstLaunch,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      notifications: notifications ?? this.notifications,
      autoBackup: autoBackup ?? this.autoBackup,
      analytics: analytics ?? this.analytics,
      language: language ?? this.language,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
    );
  }
}

// Terminal Sessions Provider
final terminalSessionsProvider = StateNotifierProvider<TerminalSessionsNotifier, List<TerminalSession>>((ref) {
  return TerminalSessionsNotifier();
});

class TerminalSessionsNotifier extends StateNotifier<List<TerminalSession>> {
  TerminalSessionsNotifier() : super([]);

  void addSession(TerminalSession session) {
    state = [...state, session];
  }

  void removeSession(String sessionId) {
    state = state.where((session) => session.id != sessionId).toList();
  }

  void updateSession(String sessionId, TerminalSession updatedSession) {
    state = state.map((session) {
      return session.id == sessionId ? updatedSession : session;
    }).toList();
  }

  TerminalSession? getSession(String sessionId) {
    try {
      return state.firstWhere((session) => session.id == sessionId);
    } catch (e) {
      return null;
    }
  }
}

class TerminalSession {
  final String id;
  final String title;
  final String workingDirectory;
  final List<String> history;
  final DateTime createdAt;
  final bool isActive;

  const TerminalSession({
    required this.id,
    required this.title,
    required this.workingDirectory,
    required this.history,
    required this.createdAt,
    required this.isActive,
  });

  TerminalSession copyWith({
    String? id,
    String? title,
    String? workingDirectory,
    List<String>? history,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return TerminalSession(
      id: id ?? this.id,
      title: title ?? this.title,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      history: history ?? this.history,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// Loading Provider
final loadingProvider = StateProvider<bool>((ref) => false);

// Error Provider
final errorProvider = StateProvider<String?>((ref) => null);

// Network Status Provider
final networkStatusProvider = StateProvider<bool>((ref) => true);

// Selected Terminal Session Provider
final selectedTerminalSessionProvider = StateProvider<String?>((ref) => null);