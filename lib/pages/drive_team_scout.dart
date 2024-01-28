import 'package:flutter/material.dart';

import '/components/loading_overlay.dart';
import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/components/snackbar.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/server.dart';
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
    serverGetDriveTeamQuestions().then((response) {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.match.name),
        leading: IconButton(
          onPressed: Navigator.of(context).maybePop,
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      drawer: const NavDrawer(),
      body: LoadingOverlay(
        child: Builder(builder: (context) {
          return QuestionDisplay(
            pages: [
              for (int partner in partners)
                QuestionPage(
                  key: '$partner',
                  title: 'Team $partner',
                  questions: QuestionConfig.driveTeamQuestions,
                ),
            ],
            submitAction: (data) async {
              LoadingOverlay.of(context).show();

              ServerResponse<void> response = await serverSubmitDriveTeamData(
                matchKey: widget.match.key,
                partners: data,
              );
              if (!context.mounted) return;

              LoadingOverlay.of(context).hide();

              if (!response.success) {
                displaySnackbar(
                    context,
                    response.message ??
                        'Something went wrong, please try again');
              } else {
                displaySnackbar(context, response.message ?? 'Success!');
              }
            },
          );
        }),
      ),
    );
  }
}
