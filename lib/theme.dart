part of 'main.dart';

const _primary = Color(0xFF3063FF);
const _onPrimary = Colors.white;
const _secondary = Color(0xFF83B9FC);
const _onSecondary = Colors.black;
const _tertiary = Color(0xFFFFD900);
const _onTertiary = Colors.black;
const _error = Colors.red;
const _onError = Colors.white;

const _lightSurface = Color(0xFFD3D3D3);
const _onLightSurface = Colors.black;
const _lightBackground = Color(0xFFFAFAFA);
const _onLightBackground = Colors.black;

const _darkSurface = Color(0xFFA9A9A9);
const _onDarkSurface = Colors.white;
const _darkBackground = Color(0xFF262626);
const _onDarkBackground = Colors.white;

ThemeData lightTheme = ThemeData(
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
);

ThemeData darkTheme = ThemeData(
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
);
