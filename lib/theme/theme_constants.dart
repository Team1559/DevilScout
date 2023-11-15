import 'package:flutter/material.dart';

const primaryColor = Color(0xFF3063FF);
const onPrimaryColor = Colors.white;
const secondaryColor = Color(0xFF83B9FC);
const onSecondaryColor = Colors.black;
const tertiaryColor = Color(0xFFFFD900);
const onTertiaryColor = Colors.black;
const errorColor = Colors.red;
const onErrorColor = Colors.white;

const surfaceColorLight = Color(0xFFD3D3D3);
const onSurfaceColorLight = Colors.black;

const surfaceColorDark = Color(0xFFA9A9A9);
const onSurfaceColorDark = Colors.white;

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
    surface: surfaceColorLight,
    onSurface: onSurfaceColorLight,
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
    surface: surfaceColorDark,
    onSurface: onSurfaceColorDark,
  ),
);
