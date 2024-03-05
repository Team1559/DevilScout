import 'package:flutter/material.dart';

import '/components/logout.dart';
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
    serverGetMatchQuestions().then(detectLogout()).then((response) {
      if (response.value != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Team ${widget.team}'),
      ),
      body: QuestionDisplay(
        pages: QuestionConfig.matchQuestions,
        submitAction: (context, data) => serverSubmitMatchData(
          matchKey: widget.match.key,
          team: widget.team,
          data: data,
        ).then(detectLogout(context)),
      ),
    );
  }
}
