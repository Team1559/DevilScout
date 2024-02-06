import 'package:flutter/material.dart';

import '/components/menu_scaffold.dart';
import '/components/no_event_set.dart';
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
          child: RefreshIndicator(
            onRefresh: refresh,
            child: ListView.builder(
              itemCount: TeamStatistics.currentList.length,
              itemBuilder: (context, index) => TeamCard(
                statistics: TeamStatistics.currentList[index],
                team: FrcTeam.currentEventTeams.singleWhere(
                  (t) => t.number == TeamStatistics.currentList[index].team,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class TeamCard extends StatelessWidget {
  final FrcTeam team;
  final TeamStatistics statistics;

  const TeamCard({super.key, required this.team, required this.statistics});

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
            builder: (context) => TeamAnalysisPage(statistics: statistics),
          ),
        ),
      ),
    );
  }
}
