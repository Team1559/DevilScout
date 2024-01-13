import 'package:flutter/material.dart';

import '/server/session_file.dart';
import 'login.dart';
import 'match_scout_select.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    loadSessionFromFile().then((isLoggedIn) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                isLoggedIn ? const MatchSelectPage() : const LoginPage(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Loading...",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.left,
            ),
          ],
        ),
      ),
    );
  }
}
