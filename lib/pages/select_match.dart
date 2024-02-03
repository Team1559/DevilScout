import 'package:flutter/material.dart';

import '/components/match_card.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/pages/scout_match.dart';
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

    // Update event information for UI
    loadMatches();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule(),
    ]).whenComplete(() => setState(() {
          loadMatches();
          _loaded = true;
        }));

    // Preload the list of teams
    serverGetCurrentEventTeamList();
  }

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
    return MenuScaffold(
      title: 'Select Match',
      body: Builder(
        builder: (context) {
          if (!Team.current!.hasEventKey) {
            return const NoEventSetWidget();
          } else if (EventMatch.currentEventSchedule.isEmpty && !_loaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return Scrollbar(
            child: Padding(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  // top: 20,
                ),
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                    child: Text(
                      Event.currentEvent!.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  for (EventMatch match in uncompletedMatches)
                    MatchCard(
                      match: match,
                      onTap: (match) => showMatchDialog(context, match),
                    ),
                  if (_showingCompleted)
                    for (EventMatch match in completedMatches)
                      MatchCard(
                        match: match,
                        onTap: (match) => showMatchDialog(context, match),
                      ),
                  if (!_showingCompleted)
                    TextButton(
                      onPressed: () => setState(() => _showingCompleted = true),
                      child: const Text('Show Completed'),
                    ),
                ])),
          );
        },
      ),
    );
  }

  void showMatchDialog(BuildContext context, EventMatch match) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(12),
        title: const Text('Select Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < match.blue.length; i++)
              teamCard(
                context: context,
                match: match,
                index: i,
                isRed: false,
              ),
            for (int i = 0; i < match.red.length; i++)
              teamCard(
                context: context,
                match: match,
                index: i,
                isRed: true,
              ),
          ],
        ),
      ),
    );
  }

  Widget teamCard({
    required BuildContext context,
    required EventMatch match,
    required int index,
    required bool isRed,
  }) {
    int teamNum = isRed ? match.red[index] : match.blue[index];
    FrcTeam? team = FrcTeam.currentEventTeams
        .where((team) => team.number == teamNum)
        .firstOrNull;
    return Card(
      color: isRed
          ? Theme.of(context).colorScheme.frcRed
          : Theme.of(context).colorScheme.frcBlue,
      child: ListTile(
        minLeadingWidth: 10,
        leading: Text(
          (index + 1).toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        title: Text(
          team?.name ?? '???',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: team == null
            ? null
            : Text(
                team.location,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelMedium,
              ),
        trailing: Text(
          teamNum.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchScoutPage(
              match: match,
              team: teamNum,
            ),
          ),
        ),
      ),
    );
  }
}
