import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const TextStyle _headingFont = TextStyle(fontFamily: 'Montserrat');
const TextStyle _bodyFont = TextStyle(fontFamily: 'Inter');

const Color _primary = Color(0xFF3063FF);
const Color _secondary = Color(0xFF83B9FC);

const _textTheme = TextTheme(
  displayLarge: _headingFont,
  displayMedium: _headingFont,
  displaySmall: _headingFont,
  headlineLarge: _headingFont,
  headlineMedium: _headingFont,
  headlineSmall: _headingFont,
  titleLarge: _headingFont,
  titleMedium: _headingFont,
  titleSmall: _headingFont,
  bodyLarge: _bodyFont,
  bodyMedium: _bodyFont,
  bodySmall: _bodyFont,
  labelLarge: _bodyFont,
  labelMedium: _bodyFont,
  labelSmall: _bodyFont,
);

final lightTheme = ThemeData(
  colorScheme: const ColorScheme.light(
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    error: Color(0xFFF44336),
    onError: Colors.white,
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF494949),
    surface: Color(0xFFEBEBEB),
    onSurface: Colors.black,
    surfaceTint: Colors.transparent,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFFAFAFA),
    foregroundColor: Colors.black,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
  textTheme: _textTheme,
  filledButtonTheme: const FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: MaterialStatePropertyAll(
        Size(120, 48),
      ),
      maximumSize: MaterialStatePropertyAll(
        Size(double.infinity, 48),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
    ),
  ),
  dividerColor: Colors.transparent,
  cardTheme: const CardTheme(
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
);

final darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    error: Color(0xFFB71C1C),
    onError: Colors.white,
    background: Color(0xFF262626),
    onBackground: Color(0xFFDDDDDD),
    surface: Color(0xFF404040),
    onSurface: Color(0xFFDDDDDD),
    surfaceTint: Colors.transparent,
  ),
  appBarTheme: lightTheme.appBarTheme.copyWith(
    backgroundColor: const Color(0xFF262626),
    foregroundColor: Colors.white,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  textTheme: _textTheme,
  filledButtonTheme: lightTheme.filledButtonTheme,
  dividerColor: lightTheme.dividerColor,
  cardTheme: lightTheme.cardTheme,
);

extension MoreColors on ColorScheme {
  Color get frcRed => ThemeModeHelper.isDarkMode
      ? const Color(0xFFAA3333)
      : const Color(0xFFFF7777);
  Color get frcBlue => ThemeModeHelper.isDarkMode
      ? const Color(0xFF223399)
      : const Color(0xFF557FFF);
}

extension ThemeModeHelper on ThemeMode {
  static bool isDarkMode = false;

  ThemeMode resolve() => this == ThemeMode.system ? platform() : this;

  static ThemeMode platform() =>
      switch (SchedulerBinding.instance.platformDispatcher.platformBrightness) {
        Brightness.light => ThemeMode.light,
        Brightness.dark => ThemeMode.dark,
      };
}
