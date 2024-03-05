import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/components/team_card.dart';
import '/pages/scout/scout_pit.dart';
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
    refresh();
  }

  Future<void> refresh() => Future.wait([
        serverGetCurrentEvent().then(detectLogout()),
        serverGetCurrentEventTeamList().then(detectLogout()),
      ]).whenComplete(() => setState(() => loaded = true));

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return MenuScaffold(
      title: 'Event Teams',
      body: Builder(builder: (context) {
        if (!Team.current!.hasEventKey) {
          return const NoEventSetWidget();
        } else if (FrcTeam.currentEventTeams.isEmpty && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: FrcTeam.currentEventTeams.length,
                itemBuilder: (context, index) {
                  FrcTeam team = FrcTeam.currentEventTeams[index];
                  return TeamCard(
                    teamNum: team.number,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PitScoutPage(team: team),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
