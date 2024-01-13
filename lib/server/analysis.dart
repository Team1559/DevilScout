import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'analysis.g.dart';

@JsonSerializable(createToJson: false)
class Statistic {
  Statistic();

  factory Statistic.fromJson(Map<String, dynamic> json) =>
      _$StatisticFromJson(json);
}

@JsonSerializable(createToJson: false)
class TeamStatistics {
  final int team;
  final List<Statistic> data;

  TeamStatistics({required this.team, required this.data});

  factory TeamStatistics.fromJson(Map<String, dynamic> json) =>
      _$TeamStatisticsFromJson(json);
}

Future<ServerResponse<List<TeamStatistics>>> serverGetTeamsAnalysis() =>
    serverRequest(
      path: '/analysis/teams',
      method: 'GET',
      decoder: listOf(TeamStatistics.fromJson),
    );
