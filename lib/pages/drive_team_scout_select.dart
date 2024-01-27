import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/navigation_drawer.dart';
import '/pages/drive_team_scout.dart';
import '/server/events.dart';
import '/server/session.dart';
import '/server/teams.dart';

class DriveTeamScoutSelectPage extends StatefulWidget {
  const DriveTeamScoutSelectPage({super.key});

  @override
  State<DriveTeamScoutSelectPage> createState() =>
      DriveTeamScoutSelectPageState();
}

class DriveTeamScoutSelectPageState
    extends State<DriveTeamScoutSelectPage> {
  @override
  void initState() {
    super.initState();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule(),
    ]).whenComplete(() => setState(() {}));

    // Preload list of teams
    serverGetCurrentEventTeamList();
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
        if (!Team.current!.hasEventKey) {
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
          itemCount: EventMatch.currentTeamSchedule.length,
          itemBuilder: _matchCard,
        );
      }),
    );
  }

  Widget _matchCard(BuildContext context, int index) {
    EventMatch match = EventMatch.currentTeamSchedule[index];
    return Opacity(
      opacity: match.completed ? 0.7 : 1,
      child: Card(
        child: ListTile(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriveTeamScoutPage(
                match: match,
              ),
            ),
          ),
          iconColor: Colors.black,
          leading: Builder(
            builder: (context) => Icon(
              Icons.star,
              color: match.blue.contains(Session.current!.team)
                  ? Colors.blue
                  : Colors.red,
            ),
          ),
          title: Text(match.name),
          trailing: Text(DateFormat('h:mm a').format(match.time)),
        ),
      ),
    );
  }
}
