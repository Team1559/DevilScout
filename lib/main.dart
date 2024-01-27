import 'package:flutter/material.dart';

import '/pages/home.dart';
import 'settings.dart';
import 'theme.dart';

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
          settings!.addListener(() => setState(() {}));
        }));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings?.theme,
      debugShowCheckedModeBanner: false,
    );
  }
}
