import 'package:flutter/material.dart';

import '/components/match_card.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/server/events.dart';
import '/server/teams.dart';
import 'scout_match.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({super.key});

  @override
  State<MatchSelectPage> createState() => MatchSelectPageState();
}

class MatchSelectPageState extends State<MatchSelectPage> {
  List<EventMatch> uncompletedMatches = List.empty();
  List<EventMatch> completedMatches = List.empty();

  bool _loaded = false;

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
      subtitle: Event.currentEvent?.name,
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
                  top: 8,
                ),
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text('Upcoming Matches',
                              style: Theme.of(context).textTheme.titleLarge),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (EventMatch match in uncompletedMatches)
                    MatchCard(
                      match: match,
                      onTap: (match) => showMatchDialog(context, match),
                    ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.all(0),
                    child: ExpansionTile(
                      title: Text(
                        'Completed Matches',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      children: <Widget>[
                        for (EventMatch match in completedMatches)
                          MatchCard(
                            match: match,
                            onTap: (match) => showMatchDialog(context, match),
                          ),
                      ],
                    ),
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
        title: const Text('Select Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < match.blue.length; i++)
              teamButton(
                context: context,
                match: match,
                index: i,
                isRed: false,
              ),
            for (int i = 0; i < match.red.length; i++)
              teamButton(
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

  Widget teamButton({
    required BuildContext context,
    required EventMatch match,
    required int index,
    required bool isRed,
  }) {
    final team = isRed ? match.red[index] : match.blue[index];
    return ListTile(
      title: Text(team.toString()),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MatchScoutPage(
              match: match,
              team: team,
            ),
          ),
        );
      },
    );
  }
}
