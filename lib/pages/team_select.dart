import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/server/events.dart';
import '/server/teams.dart';
import '/server/users.dart';
import 'pit_scout.dart';

class EventTeamSelectPage extends StatefulWidget {
  const EventTeamSelectPage({super.key});

  @override
  State<EventTeamSelectPage> createState() => EventTeamSelectPageState();
}

class EventTeamSelectPageState extends State<EventTeamSelectPage> {
  @override
  void initState() {
    super.initState();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventTeamList(),
    ]).whenComplete(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Select Team'),
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
                if (User.current!.isAdmin)
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
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: FrcTeam.currentEventTeams.length,
          itemBuilder: _teamCard,
        );
      }),
    );
  }

  Widget _teamCard(context, index) {
    FrcTeam team = FrcTeam.currentEventTeams[index];
    return Card(
      child: ListTile(
        iconColor: Colors.black,
        title: Text(team.name),
        leading: Text('${team.number}'),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PitScoutPage(
              team: team.number,
            ),
          ),
        ),
      ),
    );
  }
}
