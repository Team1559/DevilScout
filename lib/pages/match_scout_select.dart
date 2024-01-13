import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/navigation_drawer.dart';
import '/server/events.dart';
import '/server/teams.dart';
import '/server/users.dart';
import 'match_scout.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({super.key});

  @override
  State<MatchSelectPage> createState() => MatchSelectPageState();
}

class MatchSelectPageState extends State<MatchSelectPage> {
  @override
  void initState() {
    super.initState();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule(),
    ]).whenComplete(() {
      setState(() {});
      // This one doesn't affect the UI
      serverGetCurrentEventTeamList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Select Match'),
            Text(
              Event.currentEvent?.name ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            )
          ],
        ),
      ),
      drawer: const NavDrawer(),
      body: Builder(builder: (context) {
        if (!Team.currentTeam!.hasEventKey) {
          return SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No event set',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  if (User.currentUser!.isAdmin)
                    FilledButton(
                      onPressed: () {},
                      child: const Text('Go to team management'),
                    )
                  else
                    Text(
                      'Ask your team admins to configure',
                      style: Theme.of(context).textTheme.bodyLarge,
                    )
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: EventMatch.currentEventSchedule.length,
          itemBuilder: _matchCard,
        );
      }),
    );
  }

  Widget _matchCard(BuildContext context, int index) {
    EventMatch match = EventMatch.currentEventSchedule[index];
    return Opacity(
      opacity: match.completed ? 0.7 : 1,
      child: Card(
        child: ExpansionTile(
          iconColor: Colors.black,
          leading: Builder(builder: (context) {
            int team = Team.currentTeam!.number;
            Color? alliance;
            if (match.blue.contains(team)) {
              alliance = Colors.blue;
            } else if (match.red.contains(team)) {
              alliance = Colors.red;
            }

            return Visibility(
              visible: alliance != null,
              maintainSize: true,
              maintainState: true,
              maintainAnimation: true,
              child: Icon(
                Icons.star,
                color: alliance,
              ),
            );
          }),
          title: Text(match.name),
          trailing: Text(DateFormat('h:mm a').format(match.time)),
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
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
          color: isRed ? Colors.red : Colors.blue,
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text('$team'),
        ),
      ),
      onTap: () async {
        if (match.completed) {
          bool cancel = await showAdaptiveDialog(
            context: context,
            builder: (context) => AlertDialog.adaptive(
              title: const Text('Match Already Completed'),
              content: const Text(
                'Are you sure you want to scout a completed match?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Back'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Continue'),
                )
              ],
            ),
          );
          if (cancel || !context.mounted) {
            return;
          }
        }

        Navigator.push(
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
