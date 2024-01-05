import 'dart:math';

import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/server/events.dart';
import '/server/questions.dart';

class DriveTeamFeedbackPage extends StatefulWidget {
  final EventMatch match;
  final int team;

  const DriveTeamFeedbackPage({
    super.key,
    required this.match,
    required this.team,
  });

  @override
  State<DriveTeamFeedbackPage> createState() => _DriveTeamFeedbackPageState();
}

class _DriveTeamFeedbackPageState extends State<DriveTeamFeedbackPage> {
  late final int _partner1;
  late final int _partner2;

  @override
  void initState() {
    super.initState();
    serverGetDriveTeamQuestions().then((response) {
      if (response.value != null) {
        setState(() {});
      }
    });

    List<int> alliance = List.of(widget.match.blue.contains(widget.team)
        ? widget.match.blue
        : widget.match.red);
    alliance.remove(widget.team);
    _partner1 = alliance.reduce((team1, team2) => min(team1, team2));
    _partner2 = alliance.reduce((team1, team2) => max(team1, team2));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
        leadingWidth: 120,
        leading: Builder(builder: (context) {
          return Row(children: [
            IconButton(
              onPressed: Navigator.of(context).maybePop,
              icon: const Icon(Icons.arrow_back),
            ),
            IconButton(
              onPressed: Scaffold.of(context).openDrawer,
              icon: const Icon(Icons.menu),
            ),
          ]);
        }),
      ),
      drawer: const NavDrawer(),
      body: QuestionDisplay(
        questions: [
          // one set of questions per partner
          QuestionPage(
            key: '$_partner1',
            title: 'Team $_partner1',
            questions: Question.driveTeamQuestions,
          ),
          QuestionPage(
            key: '$_partner2',
            title: 'Team $_partner2',
            questions: Question.driveTeamQuestions,
          ),
        ],
        submitAction: print,
      ),
    );
  }
}
