import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/questions.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/submissions.dart';

class PitScoutPage extends StatefulWidget {
  final FrcTeam team;

  const PitScoutPage({super.key, required this.team});

  @override
  State<PitScoutPage> createState() => _PitScoutPageState();
}

class _PitScoutPageState extends State<PitScoutPage> {
  @override
  void initState() {
    super.initState();
    serverGetPitQuestions().then(detectLogout()).then((response) {
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
        title: Text('Team ${widget.team.number}'),
      ),
      body: QuestionDisplay(
        pages: QuestionConfig.pitQuestions,
        submitAction: (context, data) => serverSubmitPitData(
          eventKey: Event.current!.key,
          team: widget.team.number,
          data: data,
        ).then(detectLogout(context)),
      ),
    );
  }
}
