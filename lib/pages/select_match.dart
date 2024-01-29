import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  bool _loaded = false;

  @override
  void initState() {
    super.initState();

    // Update event information for UI
    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule(),
    ]).whenComplete(() => setState(() => _loaded = true));

    // Preload the list of teams
    serverGetCurrentEventTeamList();
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
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: EventMatch.currentEventSchedule.length,
              itemBuilder: (context, index) => MatchCard(
                match: EventMatch.currentEventSchedule[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

class MatchCard extends StatelessWidget {
  static final DateFormat timeFormat = DateFormat('EEEE\nh:mm a');

  final EventMatch match;

  const MatchCard({super.key, required this.match});

  @override
  Widget build(BuildContext context) {
    Color? alliance;
    if (match.blue.contains(Team.current!.number)) {
      alliance = Colors.blue;
    } else if (match.red.contains(Team.current!.number)) {
      alliance = Colors.red;
    }

    return Opacity(
      opacity: match.completed ? 0.5 : 1,
      child: Card(
        child: ExpansionTile(
          leading: Visibility(
            visible: alliance != null,
            maintainSize: true,
            maintainState: true,
            maintainAnimation: true,
            child: Icon(
              Icons.star,
              color: alliance,
            ),
          ),
          title: Text(
            match.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: Text(
            timeFormat.format(match.time),
            textAlign: TextAlign.end,
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Table(
                  children: [
                    TableRow(
                      children: List.generate(
                        match.blue.length,
                        (index) => _teamButton(
                          context: context,
                          match: match,
                          index: index,
                          isRed: false,
                        ),
                      ),
                    ),
                    TableRow(
                      children: List.generate(
                        match.red.length,
                        (index) => _teamButton(
                          context: context,
                          match: match,
                          index: index,
                          isRed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _teamButton({
    required BuildContext context,
    required EventMatch match,
    required int index,
    required bool isRed,
  }) {
    List<int> alliance = isRed ? match.red : match.blue;
    int team = alliance[index];

    double leftPadding = index == 0 ? 0 : 1;
    double rightPadding = index == alliance.length - 1 ? 0 : 1;
    double topPadding = isRed ? 1 : 0;
    double bottomPadding = isRed ? 0 : 1;

    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            leftPadding, topPadding, rightPadding, bottomPadding),
        child: Container(
          color: isRed ? frcRed : frcBlue,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text(
            '$team',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      onTap: () async {
        if (!match.completed) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MatchScoutPage(
                match: match,
                team: team,
              ),
            ),
          );
          return;
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Match Already Completed'),
            content: const Text(
              'Are you sure you want to scout this match?',
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Back'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchScoutPage(
                      match: match,
                      team: team,
                    ),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ],
          ),
        );
      },
    );
  }
}
