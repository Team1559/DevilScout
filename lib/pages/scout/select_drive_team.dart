import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/match_card.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/pages/scout/scout_drive_team.dart';
import '/server/events.dart';
import '/server/teams.dart';

class DriveTeamSelectPage extends StatefulWidget {
  const DriveTeamSelectPage({super.key});

  @override
  State<DriveTeamSelectPage> createState() => DriveTeamSelectPageState();
}

class DriveTeamSelectPageState extends State<DriveTeamSelectPage> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() => Future.wait([
        serverGetCurrentEvent().then(detectLogout()),
        serverGetCurrentEventSchedule().then(detectLogout()),
        serverGetCurrentEventTeamList().then(detectLogout()),
      ]).whenComplete(() => setState(() => loaded = true));

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return MenuScaffold(
      title: 'Drive Team Scouting',
      body: Builder(builder: (context) {
        if (!Team.current.hasEventKey) {
          return const NoEventSetWidget();
        } else if (EventMatch.currentTeamSchedule.isEmpty && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: EventMatch.currentTeamSchedule.length,
                itemBuilder: (context, index) => MatchCard(
                  match: EventMatch.currentTeamSchedule[index],
                  onTap: (match) => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DriveTeamScoutPage(
                        match: match,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
