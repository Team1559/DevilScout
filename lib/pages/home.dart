import 'package:flutter/material.dart';

import '/server/session.dart';
import '/server/session_file.dart';
import '/server/teams.dart';
import '/server/users.dart';
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
    loadSessionFromFile().then((session) {
      if (!context.mounted) return;

      if (session == null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      Session.current = session;
      Future.wait([
        serverGetCurrentUser(),
        serverGetCurrentTeam(),
      ]);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MatchSelectPage()),
      );
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
