import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
import '/components/team_card.dart';
import '/pages/analyze/analyze_team.dart';
import '/server/analysis.dart';
import '/server/events.dart';
import '/server/teams.dart';

class TeamAnalysisSelectPage extends StatefulWidget {
  const TeamAnalysisSelectPage({super.key});

  @override
  State<TeamAnalysisSelectPage> createState() => TeamAnalysisSelectPageState();
}

class TeamAnalysisSelectPageState extends State<TeamAnalysisSelectPage> {
  bool loaded = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() => Future.wait([
        serverGetCurrentEvent().then(detectLogout()),
        serverGetCurrentEventTeamList().then(detectLogout()),
        serverGetCurrentEventTeamAnalysis().then(detectLogout()),
      ]).whenComplete(() => setState(() => loaded = true));

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return MenuScaffold(
      title: 'Team Analysis',
      body: Builder(builder: (context) {
        if (!Team.current.hasEventKey) {
          return const NoEventSetWidget();
        } else if (EventTeamStatistics.current == null && !loaded) {
          return const Center(child: CircularProgressIndicator());
        }

        return Scrollbar(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView(
                children: [
                  for (MapEntry<int, List<StatisticsPage>> entry
                      in EventTeamStatistics.current?.teams.entries ?? [])
                    TeamCard(
                      teamNum: entry.key,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeamAnalysisPage(
                            teamNum: entry.key,
                            statistics: entry.value,
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
