import 'package:devil_scout/components/loading_overlay.dart';
import 'package:devil_scout/components/snackbar.dart';
import 'package:devil_scout/server/submissions.dart';
import 'package:flutter/material.dart';

import '../server/server.dart';
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
      body: LoadingOverlay(
        child: Builder(builder: (context) {
          return QuestionDisplay(
            pages: QuestionConfig.matchQuestions,
            submitAction: (data) async {
              LoadingOverlay.of(context).show();

              ServerResponse<void> response = await serverSubmitMatchData(
                eventKey: Event.currentEvent!.key,
                matchKey: widget.match.key,
                team: widget.team,
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
