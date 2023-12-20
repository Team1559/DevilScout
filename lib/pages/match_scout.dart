import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/server/events.dart';
import '/server/questions.dart';

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
        title: Column(children: [
          Text('Team ${widget.team}'),
          Text(
            widget.match.name,
            style: Theme.of(context).textTheme.labelSmall,
          )
        ]),
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
          ('Autonomous', MatchQuestions.current?.auto),
          ('Teleop', MatchQuestions.current?.teleop),
          ('Endgame', MatchQuestions.current?.endgame),
          ('General', MatchQuestions.current?.general),
          ('Humans', MatchQuestions.current?.human),
        ],
        submitAction: (data) {},
      ),
    );
  }
}
