import 'package:flutter/material.dart';

const _primary = Color(0xFF3063FF);
const _onPrimary = Colors.white;
const _secondary = Color(0xFF83B9FC);
const _onSecondary = Colors.black;
const _tertiary = Color(0xFFFFD900);
const _onTertiary = Colors.black;
const _error = Colors.red;
const _onError = Colors.white;

const _lightSurface = Color(0xFFE4E4E4);
const _onLightSurface = Colors.black;
const _lightBackground = Color(0xFFFAFAFA);
const _onLightBackground = Color(0xFF494949);

const _darkSurface = Color(0xFFA9A9A9);
const _onDarkSurface = Colors.white;
const _darkBackground = Color(0xFF262626);
const _onDarkBackground = Colors.white;

final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: _secondary,
    onSecondary: _onSecondary,
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    error: _error,
    onError: _onError,
    background: _lightBackground,
    onBackground: _onLightBackground,
    surface: _lightSurface,
    onSurface: _onLightSurface,
  ),
  dividerColor: Colors.transparent,
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: _lightBackground,
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: ButtonStyle(
      minimumSize: const MaterialStatePropertyAll(
        Size(120, 48.0),
      ),
      maximumSize: const MaterialStatePropertyAll(
        Size(double.infinity, 48.0),
      ),
      shape: MaterialStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Montserrat',
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    labelLarge: TextStyle(
      fontFamily: 'Inter',
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
    ),
  ),
);

final darkTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: _primary,
    onPrimary: _onPrimary,
    secondary: _secondary,
    onSecondary: _onSecondary,
    tertiary: _tertiary,
    onTertiary: _onTertiary,
    error: _error,
    onError: _onError,
    background: _darkBackground,
    onBackground: _onDarkBackground,
    surface: _darkSurface,
    onSurface: _onDarkSurface,
  ),
  dividerColor: Colors.transparent,
);
