import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/navigation_drawer.dart';
import '/pages/drive_team_feedback.dart';
import '/server/events.dart';
import '/server/session.dart';
import '/server/teams.dart';

class DriveTeamFeedbackSelectPage extends StatefulWidget {
  const DriveTeamFeedbackSelectPage({super.key});

  @override
  State<DriveTeamFeedbackSelectPage> createState() => DriveTeamFeedbackSelectPageState();
}

class DriveTeamFeedbackSelectPageState extends State<DriveTeamFeedbackSelectPage> {
  final int _team = Session.current!.team;

  List<EventMatch> _matches = List.empty();

  @override
  void initState() {
    super.initState();
    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule().whenComplete(() {
        _matches = List.of(EventMatch.currentEventSchedule);
        _matches.retainWhere(
          (element) =>
              element.blue.contains(_team) || element.red.contains(_team),
        );
      }),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No event set',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                FilledButton(
                  onPressed: () {},
                  child: const Text('Go to team management'),
                )
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: _matches.length,
          itemBuilder: _matchCard,
        );
      }),
    );
  }

  Widget _matchCard(BuildContext context, int index) {
    EventMatch match = _matches[index];
    return Opacity(
      opacity: match.completed ? 0.7 : 1,
      child: Card(
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriveTeamFeedbackPage(
                match: match,
                team: _team,
              ),
            ),
          ),
          iconColor: Colors.black,
          leading: Builder(
            builder: (context) => Icon(
              Icons.star,
              color: match.blue.contains(_team) ? Colors.blue : Colors.red,
            ),
          ),
          title: Text(match.name),
          trailing: Text(DateFormat('h:mm a').format(match.time)),
        ),
      ),
    );
  }
}
