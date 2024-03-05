import 'package:flutter/material.dart';

import '/components/analysis.dart';
import '/server/analysis.dart';

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
      ),
      body: AnalysisDisplay(pages: statistics),
    );
  }
}
