import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/components/menu_scaffold.dart';
import '/pages/manage.dart';
import '/pages/scout_drive_team.dart';
import '/server/events.dart';
import '/server/session.dart';
import '/server/teams.dart';
import '/theme.dart';

class DriveTeamSelectPage extends StatefulWidget {
  const DriveTeamSelectPage({super.key});

  @override
  State<DriveTeamSelectPage> createState() => DriveTeamSelectPageState();
}

class DriveTeamSelectPageState extends State<DriveTeamSelectPage> {
  static final DateFormat timeFormat = DateFormat('EEEE\nh:mm a');

  bool loaded = false;

  @override
  void initState() {
    super.initState();

    Future.wait([
      serverGetCurrentEvent(),
      serverGetCurrentEventSchedule(),
    ]).whenComplete(() => setState(() => loaded = true));

    // Preload list of teams
    serverGetCurrentEventTeamList();
  }

  @override
  Widget build(BuildContext context) {
    return MenuScaffold(
      title: 'Select Match',
      subtitle: Event.currentEvent?.name,
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
              ],
            ),
          );
        }

        if (EventMatch.currentTeamSchedule.isEmpty && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: EventMatch.currentTeamSchedule.length,
            itemBuilder: _matchCard,
          ),
        );
      }),
    );
  }

  Widget _matchCard(BuildContext context, int index) {
    EventMatch match = EventMatch.currentTeamSchedule[index];

    List<int> partners = List.of(
        match.blue.contains(Team.current!.number) ? match.blue : match.red)
      ..remove(Team.current!.number)
      ..sort();
    String partnersStr = partners.toString();
    partnersStr = partnersStr.substring(1, partnersStr.length - 1);

    return Opacity(
      opacity: match.completed ? 0.5 : 1,
      child: Card(
        child: ListTile(
          leading: Builder(
            builder: (context) => Icon(
              Icons.star,
              color:
                  match.blue.contains(Session.current!.team) ? frcBlue : frcRed,
            ),
          ),
          title: Text(
            match.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subtitle: Text(
            partnersStr,
            style: Theme.of(context).textTheme.labelMedium,
          ),
          trailing: Text(
            timeFormat.format(match.time),
            textAlign: TextAlign.end,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriveTeamScoutPage(
                match: match,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
