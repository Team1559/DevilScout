import 'package:flutter/material.dart';

import '/components/loading_overlay.dart';
import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/components/snackbar.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/server.dart';
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
      body: LoadingOverlay(
        child: Builder(builder: (context) {
          return QuestionDisplay(
            pages: QuestionConfig.pitQuestions,
            submitAction: (data) async {
              LoadingOverlay.of(context).show();

              ServerResponse<void> response = await serverSubmitPitData(
                eventKey: Event.currentEvent!.key,
                team: widget.team.number,
                data: data,
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
