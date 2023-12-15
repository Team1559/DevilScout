import 'package:devil_scout/pages/match_select_page.dart';
import 'package:flutter/material.dart';

import '/pages/login_page.dart';

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/scouting/match/select': (context) => const MatchSelectPage(),
      },
    );
  }

  void setThemeMode(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  bool isDarkTheme() => _themeMode == ThemeMode.dark;
}
