import 'package:flutter/material.dart';

import '/components/loading_overlay.dart';
import '/pages/login.dart';
import '/pages/match_scout_select.dart';
import '/server/session.dart';

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
      home: FutureBuilder(
          future: Session.loadFromFile(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return snapshot.data!
                  ? const MatchSelectPage()
                  : const LoginPage();
            } else {
              return const LoadingOverlay(
                showByDefault: true,
                child: LoginPage(),
              );
            }
          }),
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
