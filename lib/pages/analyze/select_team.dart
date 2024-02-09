import 'package:flutter/material.dart';

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
        serverGetCurrentEvent(),
        serverGetCurrentEventTeamList(),
        serverGetCurrentEventTeamAnalysis(),
      ]).whenComplete(() => setState(() => loaded = true));

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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: RefreshIndicator(
              onRefresh: refresh,
              child: ListView.builder(
                itemCount: TeamStatistics.currentList.length,
                itemBuilder: (context, index) => TeamCard(
                  teamNum: TeamStatistics.currentList[index].team,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeamAnalysisPage(
                        statistics: TeamStatistics.currentList[index],
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
