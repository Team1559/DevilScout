import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/questions.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/session.dart';
import '/server/submissions.dart';

class DriveTeamScoutPage extends StatefulWidget {
  final EventMatch match;

  const DriveTeamScoutPage({
    super.key,
    required this.match,
  });

  @override
  State<DriveTeamScoutPage> createState() => _DriveTeamScoutPageState();
}

class _DriveTeamScoutPageState extends State<DriveTeamScoutPage> {
  late final List<int> partners;

  @override
  void initState() {
    super.initState();
    serverGetDriveTeamQuestions().then(detectLogout()).then((response) {
      if (response.value != null) {
        setState(() {});
      }
    });

    partners = List.of(widget.match.blue.contains(Session.current!.team)
        ? widget.match.blue
        : widget.match.red);
    partners.remove(Session.current!.team);
  }

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
      ),
      body: QuestionDisplay(
        pages: [
          for (int partner in partners)
            QuestionPage(
              key: '$partner',
              title: 'Team $partner',
              questions: QuestionConfig.driveTeamQuestions,
            ),
        ],
        submitAction: (context, data) => serverSubmitDriveTeamData(
          matchKey: widget.match.key,
          partners: data,
        ).then(detectLogout(context)),
      ),
    );
  }
}
