import 'package:flutter/material.dart';

import '/pages/login/login.dart';
import '/pages/scout/select_match.dart';
import '/server/session_file.dart';
import '/server/teams.dart';
import '/server/users.dart';

class LoadSessionPage extends StatefulWidget {
  const LoadSessionPage({super.key});

  @override
  State<LoadSessionPage> createState() => _LoadSessionPageState();
}

class _LoadSessionPageState extends State<LoadSessionPage> {
  @override
  void initState() {
    super.initState();
    loadCachedSession().then((success) {
      if (!success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
        return;
      }

      Future.wait([
        serverGetCurrentUser(),
        serverGetCurrentTeam(),
      ]).whenComplete(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MatchSelectPage()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        minimum: EdgeInsets.symmetric(horizontal: 25),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
