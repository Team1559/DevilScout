import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/match_card.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/components/team_card.dart';
import '/pages/scout/scout_match.dart';
import '/server/events.dart';
import '/server/teams.dart';
import '/theme.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({super.key});

  @override
  State<MatchSelectPage> createState() => MatchSelectPageState();
}

class MatchSelectPageState extends State<MatchSelectPage> {
  List<EventMatch> uncompletedMatches = List.empty();
  List<EventMatch> completedMatches = List.empty();

  bool _loaded = false;
  bool _showingCompleted = false;

  @override
  void initState() {
    super.initState();
    loadMatches();
    refresh();
  }

  Future<void> refresh() => Future.wait([
        serverGetCurrentEvent().then(detectLogout()),
        serverGetCurrentEventSchedule().then(detectLogout()),
        serverGetCurrentEventTeamList().then(detectLogout()),
      ]).whenComplete(() => setState(() {
            loadMatches();
            _loaded = true;
          }));

  void loadMatches() {
    uncompletedMatches = EventMatch.currentEventSchedule
        .where((match) => !match.completed)
        .toList()
      ..sort((a, b) => a.compareTo(b));
    completedMatches = EventMatch.currentEventSchedule
        .where((match) => match.completed)
        .toList()
      ..sort((a, b) => a.compareTo(b));
  }

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return MenuScaffold(
      title: 'DevilScout',
      body: Builder(
        builder: (context) {
          if (!Team.current!.hasEventKey) {
            return const NoEventSetWidget();
          } else if (EventMatch.currentEventSchedule.isEmpty && !_loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scrollbar(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: RefreshIndicator(
                onRefresh: refresh,
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8, left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Event.currentEvent!.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (EventMatch.currentEventSchedule.isEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'No matches',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ),
                      ],
                    ),
                  ),
                  for (EventMatch match in uncompletedMatches)
                    MatchCard(
                      match: match,
                      transparency: true,
                      onTap: (match) => showDialog(
                        context: context,
                        builder: (context) => TeamSelectDialog(match: match),
                      ),
                    ),
                  if (_showingCompleted)
                    for (EventMatch match in completedMatches)
                      MatchCard(
                        match: match,
                        transparency: true,
                        onTap: (match) => showDialog(
                          context: context,
                          builder: (context) => TeamSelectDialog(match: match),
                        ),
                      ),
                  if (!_showingCompleted && completedMatches.isNotEmpty)
                    TextButton(
                      onPressed: () => setState(() => _showingCompleted = true),
                      child: const Text('Show Completed'),
                    ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class TeamSelectDialog extends StatelessWidget {
  final EventMatch match;

  const TeamSelectDialog({
    super.key,
    required this.match,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const EdgeInsets.all(12),
      title: Text(match.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < match.blue.length; i++)
            TeamCard(
              teamNum: match.blue[i],
              color: Theme.of(context).colorScheme.frcBlue,
              label: (i + 1).toString(),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchScoutPage(
                    match: match,
                    team: match.blue[i],
                  ),
                ),
              ),
            ),
          for (int i = 0; i < match.red.length; i++)
            TeamCard(
              teamNum: match.red[i],
              color: Theme.of(context).colorScheme.frcRed,
              label: (i + 1).toString(),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MatchScoutPage(
                    match: match,
                    team: match.red[i],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
