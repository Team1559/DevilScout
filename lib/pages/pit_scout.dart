import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
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
    serverGetPitQuestions().then((response) {
      if (response.value != null) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team ${widget.team.number}'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            widget.team.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        leading: IconButton(
          onPressed: Navigator.of(context).maybePop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      drawer: const NavDrawer(),
      body: QuestionDisplay(
        pages: QuestionConfig.pitQuestions,
        submitAction: (data) => serverSubmitPitData(
          eventKey: Event.currentEvent!.key,
          team: widget.team.number,
          data: data,
        ),
      ),
    );
  }
}
