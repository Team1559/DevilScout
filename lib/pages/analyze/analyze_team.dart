import 'package:flutter/material.dart';

import '/components/analysis.dart';
import '/server/analysis.dart';
import '/server/events.dart';

class TeamAnalysisPage extends StatelessWidget {
  final TeamStatistics statistics;

  const TeamAnalysisPage({super.key, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team ${statistics.team}'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            FrcTeam.currentEventTeams
                .singleWhere((t) => t.number == statistics.team)
                .name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      body: AnalysisDisplay(pages: statistics.pages),
    );
  }
}
