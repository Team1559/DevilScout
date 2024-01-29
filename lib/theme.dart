import 'package:flutter/material.dart';

const Color frcBlue = Color(0xFF0066B4);
const Color frcRed = Color(0xFFED1B25);

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
const Color _secondary = Color(0xFF83B9FC);
const Color _tertiary = Color(0xFFFFD900);

final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    tertiary: _tertiary,
    onTertiary: Colors.black,
    error: Color(0xFFF44336),
    onError: Colors.white,
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF494949),
    surface: Color(0xFFE4E4E4),
    onSurface: Colors.black,
  ),
  textTheme: _textTheme,
  filledButtonTheme: _filledButtonTheme,
  dividerColor: Colors.transparent,
);

final darkTheme = ThemeData(
  colorScheme: const ColorScheme.dark(
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: Colors.white,
    secondary: _secondary,
    onSecondary: Colors.black,
    tertiary: _tertiary,
    onTertiary: Colors.black,
    error: Color(0xFFB71C1C),
    onError: Colors.white,
    background: Color(0xFF262626),
    onBackground: Color(0xFFDDDDDD),
    surface: Color(0xFF404040),
    onSurface: Color(0xFFDDDDDD),
  ),
  textTheme: _textTheme,
  filledButtonTheme: _filledButtonTheme,
  dividerColor: Colors.transparent,
);
