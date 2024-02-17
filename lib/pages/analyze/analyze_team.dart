import 'package:flutter/material.dart';

import '/components/analysis.dart';
import '/server/analysis.dart';
import '/server/events.dart';

class TeamAnalysisPage extends StatelessWidget {
  final int teamNum;
  final List<StatisticsPage> statistics;

  const TeamAnalysisPage({
    super.key,
    required this.teamNum,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team $teamNum'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            FrcTeam.currentEventTeams
                    .where((t) => t.number == teamNum)
                    .firstOrNull
                    ?.name ??
                'Unknown',
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      body: AnalysisDisplay(pages: statistics),
    );
  }
}
