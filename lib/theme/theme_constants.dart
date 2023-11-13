import 'package:flutter/material.dart';

const primaryColor = Color(0xFF3063FF);
const onPrimaryColor = Colors.white;
const secondaryColor = Color(0xFF83B9FC);
const onSecondaryColor = Colors.black;
const tertiaryColor = Color(0xFFFFD900);
const onTertiaryColor = Colors.black;
const errorColor = Colors.red;
const onErrorColor = Colors.white;
const surfaceColor = secondaryColor;
const onSurfaceColor = onSecondaryColor;

const backgroundColorLight = Color(0xFFFAFAFA);
const onBackgroundColorLight = Colors.black;

const backgroundColorDark = Color(0xFF262626);
const onBackgroundColorDark = Colors.white;

ThemeData lightTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    onSecondary: onSecondaryColor,
    tertiary: tertiaryColor,
    onTertiary: onTertiaryColor,
    error: errorColor,
    onError: onErrorColor,
    background: backgroundColorLight,
    onBackground: onBackgroundColorLight,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
  ),
);

ThemeData darkTheme = ThemeData(
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    secondary: secondaryColor,
    onSecondary: onSecondaryColor,
    tertiary: tertiaryColor,
    onTertiary: onTertiaryColor,
    error: errorColor,
    onError: onErrorColor,
    background: backgroundColorDark,
    onBackground: onBackgroundColorDark,
    surface: surfaceColor,
    onSurface: onSurfaceColor,
  ),
);
