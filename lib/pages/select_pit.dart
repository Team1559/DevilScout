import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/pages/manage.dart';
import '/pages/scout_pit.dart';
import '/server/events.dart';
import '/server/teams.dart';
import '/server/users.dart';

class PitSelectPage extends StatefulWidget {
  const PitSelectPage({super.key});

  @override
  State<PitSelectPage> createState() => PitSelectPageState();
}

class PitSelectPageState extends State<PitSelectPage> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventTeamList(),
    ]).whenComplete(() => setState(() => loaded = true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Team'),
        bottom: Event.currentEvent == null
            ? null
            : PreferredSize(
                preferredSize: Size.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    Event.currentEvent!.name,
                    style: Theme.of(context).textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
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
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (User.current!.isAdmin)
                  FilledButton(
                    child: const Text('Go to team management'),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagementPage(),
                        ),
                      );
                    },
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

        if (EventMatch.currentEventSchedule.isEmpty && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: FrcTeam.currentEventTeams.length,
            itemBuilder: _teamCard,
          ),
        );
      }),
    );
  }

  Widget _teamCard(context, index) {
    FrcTeam team = FrcTeam.currentEventTeams[index];
    return Card(
      child: ListTile(
        trailing: Text(
          '${team.number}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        title: Text(
          team.name,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          team.location,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PitScoutPage(team: team),
          ),
        ),
      ),
    );
  }
}
