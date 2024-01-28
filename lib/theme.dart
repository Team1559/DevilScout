import 'package:flutter/material.dart';

const Color frcBlue = Color(0xFF0066B4);
const Color frcRed = Color(0xFFED1B25);

const TextStyle _headingOverrides = TextStyle(
  fontFamily: 'Montserrat',
);
const TextStyle _bodyOverrides = TextStyle(
  fontFamily: 'Inter',
);

final lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF3063FF),
    onPrimary: Colors.white,
    secondary: Color(0xFF83B9FC),
    onSecondary: Colors.black,
    tertiary: Color(0xFFFFD900),
    onTertiary: Colors.black,
    error: Colors.redAccent,
    onError: Colors.white,
    background: Color(0xFFFAFAFA),
    onBackground: Color(0xFF494949),
    surface: Color(0xFFE4E4E4),
    onSurface: Colors.black,
  ),
  textTheme: const TextTheme(
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
  ),
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
);

final darkTheme = lightTheme.copyWith(
  colorScheme: lightTheme.colorScheme.copyWith(
    brightness: Brightness.dark,
    background: const Color(0xFF262626),
    onBackground: Colors.white,
    surface: const Color(0xFFA9A9A9),
    onSurface: Colors.white,
  ),
);
