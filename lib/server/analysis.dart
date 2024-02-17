import 'package:json_annotation/json_annotation.dart';

import '/server/server.dart';
import '/server/teams.dart';

part 'analysis.g.dart';

class EventTeamStatistics {
  static EventTeamStatistics? current;
  static final Etag _currentEtag = Etag();

  static void clear() {
    current = null;
    _currentEtag.clear();
  }

  final Map<int, List<StatisticsPage>> teams;

  const EventTeamStatistics({
    required this.teams,
  });

  factory EventTeamStatistics.fromJson(Map<String, dynamic> json) {
    Map<int, List<StatisticsPage>> teams = {};
    for (MapEntry<String, dynamic> entry in json.entries) {
      teams[int.parse(entry.key)] =
          listOf(StatisticsPage.fromJson).call(entry.value);
    }
    return EventTeamStatistics(teams: teams);
  }
}

@JsonSerializable(createToJson: false)
class StatisticsPage {
  final String title;
  final List<Statistic> statistics;

  const StatisticsPage({required this.title, required this.statistics});

  factory StatisticsPage.fromJson(Map<String, dynamic> json) =>
      _$StatisticsPageFromJson(json);
}

sealed class Statistic {
  final String name;

  const Statistic({required this.name});

  factory Statistic.fromJson(Map<String, dynamic> json) =>
      $enumDecode(_$StatisticTypeEnumMap, json['type'])._parser(json);
}

@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum StatisticType {
  boolean(_$BooleanStatisticFromJson),
  number(_$NumberStatisticFromJson),
  opr(_$OprStatisticFromJson),
  pieChart(_$PieChartStatisticFromJson),
  radar(_$RadarStatisticFromJson),
  rp(_$RankingPointsStatisticFromJson),
  string(_$StringStatisticFromJson),
  wtl(_$WltStatisticFromJson);

  final Statistic Function(Map<String, dynamic>) _parser;

  const StatisticType(this._parser);
}

@JsonSerializable(createToJson: false)
class BooleanStatistic extends Statistic {
  final double? percent;

  const BooleanStatistic({required super.name, this.percent});
}

@JsonSerializable(createToJson: false)
class NumberStatistic extends Statistic {
  final double? mean;
  final double? stddev;
  final double? min;
  final double? max;

  const NumberStatistic({
    required super.name,
    required this.mean,
    required this.stddev,
    required this.min,
    required this.max,
  });
}

@JsonSerializable(createToJson: false)
class OprStatistic extends Statistic {
  final double? opr;
  final double? dpr;
  final double? ccwm;

  OprStatistic({
    required super.name,
    required this.opr,
    required this.dpr,
    required this.ccwm,
  });
}

@JsonSerializable(createToJson: false)
class PieChartStatistic extends Statistic {
  final Map<String, int>? slices;

  const PieChartStatistic({
    required super.name,
    required this.slices,
  });
}

@JsonSerializable(createToJson: false)
class RadarStatistic extends Statistic {
  final double max;
  final Map<String, double?> points;

  const RadarStatistic({
    required super.name,
    required this.max,
    required this.points,
  });
}

@JsonSerializable(createToJson: false)
class RankingPointsStatistic extends Statistic {
  final Map<String, int>? points;

  const RankingPointsStatistic({required super.name, required this.points});
}

@JsonSerializable(createToJson: false)
class StringStatistic extends Statistic {
  final String? value;

  const StringStatistic({required super.name, required this.value});
}

@JsonSerializable(createToJson: false)
class WltStatistic extends Statistic {
  final int wins;
  final int losses;
  final int ties;

  const WltStatistic({
    required super.name,
    required this.wins,
    required this.losses,
    required this.ties,
  });
}

Future<ServerResponse<EventTeamStatistics>>
    serverGetCurrentEventTeamAnalysis() => serverRequest(
          path: 'analysis/${Team.current!.eventKey}/teams',
          method: 'GET',
          etag: EventTeamStatistics._currentEtag,
          decoder: EventTeamStatistics.fromJson,
          callback: (stats) => EventTeamStatistics.current = stats,
        );
