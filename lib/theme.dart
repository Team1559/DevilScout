import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

const TextStyle _headingOverrides = TextStyle(
  fontFamily: 'Montserrat',
);
const TextStyle _bodyOverrides = TextStyle(
  fontFamily: 'Inter',
);

const TextTheme _textTheme = TextTheme(
  displayLarge: _headingOverrides,
  displayMedium: _headingOverrides,
  displaySmall: _headingOverrides,
  headlineLarge: _headingOverrides,
  headlineMedium: _headingOverrides,
  headlineSmall: _headingOverrides,
  titleLarge: _headingOverrides,
  titleMedium: _headingOverrides,
  titleSmall: _headingOverrides,
  bodyLarge: _bodyOverrides,
  bodyMedium: _bodyOverrides,
  bodySmall: _bodyOverrides,
  labelLarge: _bodyOverrides,
  labelMedium: _bodyOverrides,
  labelSmall: _bodyOverrides,
);

const FilledButtonThemeData _filledButtonTheme = FilledButtonThemeData(
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
);

const Color _primary = Color(0xFF3063FF);

final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF83B9FC),
    onSecondary: Colors.black,
    error: Color(0xFFF44336),
    onError: Colors.white,
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF494949),
    surface: Color.fromARGB(255, 236, 235, 235),
    onSurface: Colors.black,
    surfaceTint: Colors.transparent,
  ),
  textTheme: _textTheme,
  filledButtonTheme: _filledButtonTheme,
  dividerColor: Colors.transparent,
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
  cardTheme: const CardTheme(
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
);

final darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: Colors.white,
    secondary: Color(0xFF182860),
    onSecondary: Colors.black,
    error: Color(0xFFB71C1C),
    onError: Colors.white,
    background: Color(0xFF262626),
    onBackground: Color(0xFFDDDDDD),
    surface: Color(0xFF404040),
    onSurface: Color(0xFFDDDDDD),
    surfaceTint: Colors.transparent,
  ),
  textTheme: _textTheme,
  filledButtonTheme: _filledButtonTheme,
  dividerColor: Colors.transparent,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF262626),
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
    scrolledUnderElevation: 0,
    centerTitle: true,
  ),
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
