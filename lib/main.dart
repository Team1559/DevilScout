import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/pages/login/load_session.dart';
import '/settings.dart';
import '/theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  AppSettings? settings;

  @override
  void initState() {
    super.initState();
    getSettings().then((value) => setState(() {
          settings = value;
          settings!.addListener(_listener);
          _listener();
        }));
  }

  @override
  void dispose() {
    super.dispose();
    settings?.removeListener(_listener);
  }

  void _listener() => setState(() {
        ThemeModeHelper.isDarkMode =
            settings!.theme.resolve() == ThemeMode.dark;
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor:
              (ThemeModeHelper.isDarkMode ? darkTheme : lightTheme)
                  .colorScheme
                  .background,
        ));
      });

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor:
          (ThemeModeHelper.isDarkMode ? darkTheme : lightTheme)
              .colorScheme
              .background,
    ));
    return MaterialApp(
      home: const LoadSessionPage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings?.theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
