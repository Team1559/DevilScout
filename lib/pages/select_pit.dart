import 'package:flutter/material.dart';

import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/pages/scout_pit.dart';
import '/server/events.dart';
import '/server/teams.dart';

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
    return MenuScaffold(
      title: 'Select Team',
      body: Builder(builder: (context) {
        if (!Team.current!.hasEventKey) {
          return const NoEventSetWidget();
        } else if (EventMatch.currentEventSchedule.isEmpty && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: ListView.builder(
            itemCount: FrcTeam.currentEventTeams.length,
            itemBuilder: (context, index) => TeamCard(
              team: FrcTeam.currentEventTeams[index],
            ),
          ),
        );
      }),
    );
  }
}

class TeamCard extends StatelessWidget {
  final FrcTeam team;

  const TeamCard({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
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
