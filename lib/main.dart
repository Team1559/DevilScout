import 'package:flutter/material.dart';

import '/pages/home.dart';

part 'theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();

  static MainAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MainAppState>()!;
}

class MainAppState extends State<MainApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
    );
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  bool isDarkTheme() => _themeMode == ThemeMode.dark;
}
