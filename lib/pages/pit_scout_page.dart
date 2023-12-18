import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/server/questions.dart';

class PitScoutPage extends StatefulWidget {
  final int team;

  const PitScoutPage({super.key, required this.team});

  @override
  State<PitScoutPage> createState() => _PitScoutPageState();
}

class _PitScoutPageState extends State<PitScoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team ${widget.team}'),
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
          ('Robot Specs', PitQuestions.current?.specs),
          ('Autonomous', PitQuestions.current?.auto),
          ('Teleop', PitQuestions.current?.teleop),
          ('Endgame', PitQuestions.current?.endgame),
          ('General', PitQuestions.current?.general),
        ],
        submitAction: (data) {},
      ),
    );
  }
}
