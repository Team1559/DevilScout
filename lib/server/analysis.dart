import 'package:json_annotation/json_annotation.dart';

import '/server/server.dart';

part 'analysis.g.dart';

@JsonSerializable(createToJson: false)
class TeamStatistics {
  final int team;
  final List<String> pages;
  final List<List<Statistic>> data;

  const TeamStatistics({
    required this.team,
    required this.pages,
    required this.data,
  });

  factory TeamStatistics.fromJson(Map<String, dynamic> json) =>
      _$TeamStatisticsFromJson(json);
}

sealed class Statistic {
  const Statistic();

  factory Statistic.fromJson(Map<String, dynamic> json) =>
      $enumDecode(_$StatisticTypeEnumMap, json['type'])._parser(json);
}

@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum StatisticType {
  number(_$NumberStatisticFromJson),
  boolean(_$BooleanStatisticFromJson),
  percentage(_$PercentageStatisticFromJson);

  final Statistic Function(Map<String, dynamic>) _parser;

  const StatisticType(this._parser);
}

@JsonSerializable(createToJson: false)
class NumberStatistic extends Statistic {
  final num min;
  final num q1;
  final num median;
  final num q3;
  final num max;

  const NumberStatistic({
    required this.min,
    required this.q1,
    required this.median,
    required this.q3,
    required this.max,
  });
}

@JsonSerializable(createToJson: false)
class BooleanStatistic extends Statistic {
  final int yes;
  final int no;
  final int total;

  const BooleanStatistic({
    required this.yes,
    required this.no,
    required this.total,
  });
}

@JsonSerializable(createToJson: false)
class PercentageStatistic extends Statistic {
  final int total;
  final List<int> counts;
  final List<String> labels;

  const PercentageStatistic({
    required this.total,
    required this.counts,
    required this.labels,
  });
}

Future<ServerResponse<List<TeamStatistics>>> serverGetTeamsAnalysis() =>
    serverRequest(
      path: 'analysis/teams',
      method: 'GET',
      decoder: listOf(TeamStatistics.fromJson),
    );
