import 'package:flutter/material.dart';

import '/components/questions.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/submissions.dart';

class MatchScoutPage extends StatefulWidget {
  final EventMatch match;
  final int team;

  const MatchScoutPage({super.key, required this.match, required this.team});

  @override
  State<MatchScoutPage> createState() => _MatchScoutPageState();
}

class _MatchScoutPageState extends State<MatchScoutPage> {
  @override
  void initState() {
    super.initState();
    serverGetMatchQuestions().then((response) {
      if (response.value != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DevilScout'),
      ),
      body: QuestionDisplay(
        pages: QuestionConfig.matchQuestions,
        submitAction: (data) => serverSubmitMatchData(
          matchKey: widget.match.key,
          team: widget.team,
          data: data,
        ),
      ),
    );
  }
}
