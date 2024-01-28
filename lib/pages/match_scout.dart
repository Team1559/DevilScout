import 'package:flutter/material.dart';

import '/components/loading_overlay.dart';
import '/components/navigation_drawer.dart';
import '/components/questions.dart';
import '/components/snackbar.dart';
import '/server/events.dart';
import '/server/questions.dart';
import '/server/server.dart';
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
        title: Text('Team ${widget.team}'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            widget.match.name,
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
            pages: QuestionConfig.matchQuestions,
            submitAction: (data) async {
              LoadingOverlay.of(context).show();

              ServerResponse<void> response = await serverSubmitMatchData(
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
