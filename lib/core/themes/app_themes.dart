import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:google_fonts/google_fonts.dart';

class AppThemes {
  // Theme Mode Provider Values
  static const String lightMode = 'light';
  static const String darkMode = 'dark';
  static const String systemMode = 'system';

  // Color Scheme Keys
  static const String hackerGreen = 'hacker_green';
  static const String monokai = 'monokai';
  static const String dracula = 'dracula';
  static const String cyberpunk = 'cyberpunk';
  static const String matrix = 'matrix';
  static const String synthwave = 'synthwave';
  static const String nord = 'nord';
  static const String gruvbox = 'gruvbox';
  static const String oneDark = 'one_dark';
  static const String solarized = 'solarized';

  // Light Theme
  static ThemeData lightTheme(String colorScheme) {
    final flexScheme = _getFlexColorScheme(colorScheme, Brightness.light);
    
    return FlexThemeData.light(
      scheme: flexScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 7,
      subThemesData: _getSubThemesData(),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    ).copyWith(
      textTheme: _getTextTheme(Brightness.light),
      appBarTheme: _getAppBarTheme(Brightness.light, flexScheme),
    );
  }

  // Dark Theme
  static ThemeData darkTheme(String colorScheme) {
    final flexScheme = _getFlexColorScheme(colorScheme, Brightness.dark);
    
    return FlexThemeData.dark(
      scheme: flexScheme,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 13,
      subThemesData: _getSubThemesData(),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      fontFamily: GoogleFonts.inter().fontFamily,
    ).copyWith(
      textTheme: _getTextTheme(Brightness.dark),
      appBarTheme: _getAppBarTheme(Brightness.dark, flexScheme),
    );
  }

  // Get Flex Color Scheme
  static FlexScheme _getFlexColorScheme(String colorScheme, Brightness brightness) {
    switch (colorScheme) {
      case hackerGreen:
        return FlexScheme.green;
      case monokai:
        return FlexScheme.ebonyClay;
      case dracula:
        return FlexScheme.deepPurple;
      case cyberpunk:
        return FlexScheme.electricViolet;
      case matrix:
        return FlexScheme.money;
      case synthwave:
        return FlexScheme.purpleBrown;
      case nord:
        return FlexScheme.indigo;
      case gruvbox:
        return FlexScheme.brown;
      case oneDark:
        return FlexScheme.greyLaw;
      case solarized:
        return FlexScheme.amber;
      default:
        return FlexScheme.materialBaseline;
    }
  }

  // Sub Themes Data
  static FlexSubThemesData _getSubThemesData() {
    return const FlexSubThemesData(
      interactionEffects: true,
      tintedDisabledControls: true,
      useM2StyleDividerInM3: true,
      inputDecoratorRadius: 12.0,
      inputDecoratorUnfocusedHasBorder: true,
      blendOnColors: true,
      blendTextTheme: true,
      popupMenuRadius: 8.0,
      popupMenuElevation: 8.0,
      alignedDropdown: true,
      useInputDecoratorThemeInDialogs: true,
      cardRadius: 12.0,
      cardElevation: 4.0,
      dialogRadius: 20.0,
      timePickerDialogRadius: 20.0,
      snackBarRadius: 8.0,
      appBarScrolledUnderElevation: 4.0,
      bottomSheetRadius: 20.0,
      bottomNavigationBarMutedUnselectedLabel: true,
      bottomNavigationBarMutedUnselectedIcon: true,
      menuRadius: 8.0,
      menuElevation: 8.0,
      navigationBarSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedLabel: true,
      navigationBarSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationBarMutedUnselectedIcon: true,
      navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationBarIndicatorOpacity: 1.00,
      navigationRailSelectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedLabelSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedLabel: true,
      navigationRailSelectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailUnselectedIconSchemeColor: SchemeColor.onSurface,
      navigationRailMutedUnselectedIcon: true,
      navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
      navigationRailIndicatorOpacity: 1.00,
    );
  }

  // Text Theme
  static TextTheme _getTextTheme(Brightness brightness) {
    return GoogleFonts.interTextTheme().copyWith(
      // Terminal specific text styles
      bodyLarge: GoogleFonts.jetBrainsMono(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      bodySmall: GoogleFonts.jetBrainsMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // App Bar Theme
  static AppBarTheme _getAppBarTheme(Brightness brightness, FlexScheme scheme) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 4,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // Terminal Color Schemes
  static Map<String, TerminalColorScheme> get terminalColorSchemes => {
    hackerGreen: TerminalColorScheme(
      name: 'Hacker Green',
      background: const Color(0xFF000000),
      foreground: const Color(0xFF00FF00),
      cursor: const Color(0xFF00FF00),
      selection: const Color(0xFF333333),
      black: const Color(0xFF000000),
      red: const Color(0xFFFF0000),
      green: const Color(0xFF00FF00),
      yellow: const Color(0xFFFFFF00),
      blue: const Color(0xFF0000FF),
      magenta: const Color(0xFFFF00FF),
      cyan: const Color(0xFF00FFFF),
      white: const Color(0xFFFFFFFF),
      brightBlack: const Color(0xFF808080),
      brightRed: const Color(0xFFFF8080),
      brightGreen: const Color(0xFF80FF80),
      brightYellow: const Color(0xFFFFFF80),
      brightBlue: const Color(0xFF8080FF),
      brightMagenta: const Color(0xFFFF80FF),
      brightCyan: const Color(0xFF80FFFF),
      brightWhite: const Color(0xFFFFFFFF),
    ),
    
    monokai: TerminalColorScheme(
      name: 'Monokai',
      background: const Color(0xFF272822),
      foreground: const Color(0xFFF8F8F2),
      cursor: const Color(0xFFF8F8F0),
      selection: const Color(0xFF49483E),
      black: const Color(0xFF272822),
      red: const Color(0xFFF92672),
      green: const Color(0xFFA6E22E),
      yellow: const Color(0xFFF4BF75),
      blue: const Color(0xFF66D9EF),
      magenta: const Color(0xFFAE81FF),
      cyan: const Color(0xFFA1EFE4),
      white: const Color(0xFFF8F8F2),
      brightBlack: const Color(0xFF75715E),
      brightRed: const Color(0xFFF92672),
      brightGreen: const Color(0xFFA6E22E),
      brightYellow: const Color(0xFFF4BF75),
      brightBlue: const Color(0xFF66D9EF),
      brightMagenta: const Color(0xFFAE81FF),
      brightCyan: const Color(0xFFA1EFE4),
      brightWhite: const Color(0xFFF9F8F5),
    ),
    
    dracula: TerminalColorScheme(
      name: 'Dracula',
      background: const Color(0xFF282A36),
      foreground: const Color(0xFFF8F8F2),
      cursor: const Color(0xFFF8F8F2),
      selection: const Color(0xFF44475A),
      black: const Color(0xFF000000),
      red: const Color(0xFFFF5555),
      green: const Color(0xFF50FA7B),
      yellow: const Color(0xFFF1FA8C),
      blue: const Color(0xFFBD93F9),
      magenta: const Color(0xFFFF79C6),
      cyan: const Color(0xFF8BE9FD),
      white: const Color(0xFFBBBBBB),
      brightBlack: const Color(0xFF555555),
      brightRed: const Color(0xFFFF5555),
      brightGreen: const Color(0xFF50FA7B),
      brightYellow: const Color(0xFFF1FA8C),
      brightBlue: const Color(0xFFBD93F9),
      brightMagenta: const Color(0xFFFF79C6),
      brightCyan: const Color(0xFF8BE9FD),
      brightWhite: const Color(0xFFFFFFFF),
    ),
    
    cyberpunk: TerminalColorScheme(
      name: 'Cyberpunk',
      background: const Color(0xFF0A0E1A),
      foreground: const Color(0xFF00D4FF),
      cursor: const Color(0xFFFF0080),
      selection: const Color(0xFF1A1A2E),
      black: const Color(0xFF000000),
      red: const Color(0xFFFF0080),
      green: const Color(0xFF00FF41),
      yellow: const Color(0xFFFFFF00),
      blue: const Color(0xFF0080FF),
      magenta: const Color(0xFFFF0080),
      cyan: const Color(0xFF00D4FF),
      white: const Color(0xFFFFFFFF),
      brightBlack: const Color(0xFF808080),
      brightRed: const Color(0xFFFF4081),
      brightGreen: const Color(0xFF69FF94),
      brightYellow: const Color(0xFFFFFF8D),
      brightBlue: const Color(0xFF40C4FF),
      brightMagenta: const Color(0xFFFF4081),
      brightCyan: const Color(0xFF18FFFF),
      brightWhite: const Color(0xFFFFFFFF),
    ),
    
    matrix: TerminalColorScheme(
      name: 'Matrix',
      background: const Color(0xFF000000),
      foreground: const Color(0xFF00FF41),
      cursor: const Color(0xFF00FF41),
      selection: const Color(0xFF003300),
      black: const Color(0xFF000000),
      red: const Color(0xFF008000),
      green: const Color(0xFF00FF41),
      yellow: const Color(0xFF80FF00),
      blue: const Color(0xFF008080),
      magenta: const Color(0xFF40FF40),
      cyan: const Color(0xFF00FF80),
      white: const Color(0xFF80FF80),
      brightBlack: const Color(0xFF404040),
      brightRed: const Color(0xFF40C040),
      brightGreen: const Color(0xFF60FF60),
      brightYellow: const Color(0xFFA0FF40),
      brightBlue: const Color(0xFF40C0C0),
      brightMagenta: const Color(0xFF80FF80),
      brightCyan: const Color(0xFF40FFC0),
      brightWhite: const Color(0xFFA0FFA0),
    ),
    
    synthwave: TerminalColorScheme(
      name: 'Synthwave',
      background: const Color(0xFF2b213a),
      foreground: const Color(0xFFf92aad),
      cursor: const Color(0xFFf92aad),
      selection: const Color(0xFF495495),
      black: const Color(0xFF000000),
      red: const Color(0xFFf97e72),
      green: const Color(0xFF72f1b8),
      yellow: const Color(0xFFfede5d),
      blue: const Color(0xFF6bcdef),
      magenta: const Color(0xFFf92aad),
      cyan: const Color(0xFF2de2e6),
      white: const Color(0xFFf7f3ff),
      brightBlack: const Color(0xFF495495),
      brightRed: const Color(0xFFf97e72),
      brightGreen: const Color(0xFF72f1b8),
      brightYellow: const Color(0xFFfede5d),
      brightBlue: const Color(0xFF6bcdef),
      brightMagenta: const Color(0xFFf92aad),
      brightCyan: const Color(0xFF2de2e6),
      brightWhite: const Color(0xFFffffff),
    ),
  };

  // Terminal Font Families
  static List<String> get terminalFonts => [
    'JetBrainsMono',
    'FiraCode',
    'HackNerdFont',
    'Consolas',
    'Monaco',
    'Menlo',
    'Ubuntu Mono',
    'Source Code Pro',
  ];

  // Font Sizes
  static List<double> get fontSizes => [
    8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, 16.0, 18.0, 20.0, 22.0, 24.0
  ];
}

// Terminal Color Scheme Model
class TerminalColorScheme {
  final String name;
  final Color background;
  final Color foreground;
  final Color cursor;
  final Color selection;
  final Color black;
  final Color red;
  final Color green;
  final Color yellow;
  final Color blue;
  final Color magenta;
  final Color cyan;
  final Color white;
  final Color brightBlack;
  final Color brightRed;
  final Color brightGreen;
  final Color brightYellow;
  final Color brightBlue;
  final Color brightMagenta;
  final Color brightCyan;
  final Color brightWhite;

  const TerminalColorScheme({
    required this.name,
    required this.background,
    required this.foreground,
    required this.cursor,
    required this.selection,
    required this.black,
    required this.red,
    required this.green,
    required this.yellow,
    required this.blue,
    required this.magenta,
    required this.cyan,
    required this.white,
    required this.brightBlack,
    required this.brightRed,
    required this.brightGreen,
    required this.brightYellow,
    required this.brightBlue,
    required this.brightMagenta,
    required this.brightCyan,
    required this.brightWhite,
  });

  Map<String, Color> get colorMap => {
    'background': background,
    'foreground': foreground,
    'cursor': cursor,
    'selection': selection,
    'black': black,
    'red': red,
    'green': green,
    'yellow': yellow,
    'blue': blue,
    'magenta': magenta,
    'cyan': cyan,
    'white': white,
    'bright_black': brightBlack,
    'bright_red': brightRed,
    'bright_green': brightGreen,
    'bright_yellow': brightYellow,
    'bright_blue': brightBlue,
    'bright_magenta': brightMagenta,
    'bright_cyan': brightCyan,
    'bright_white': brightWhite,
  };
}