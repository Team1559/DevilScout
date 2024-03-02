import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

import '/components/horizontal_view.dart';
import '/components/radar_chart.dart';
import '/server/analysis.dart';

class AnalysisDisplay extends HorizontalPageView<StatisticsPage> {
  const AnalysisDisplay({super.key, required super.pages});

  @override
  State<AnalysisDisplay> createState() => _AnalysisDisplayState();
}

class _AnalysisDisplayState
    extends HorizontalPageViewState<StatisticsPage, AnalysisDisplay> {
  @override
  Widget buildPage(StatisticsPage page) {
    return _StatisticsDisplayPage(
      title: page.title,
      statistics: page.statistics,
    );
  }
}

class _StatisticsDisplayPage extends StatelessWidget {
  final String title;
  final List<Statistic> statistics;

  const _StatisticsDisplayPage({required this.title, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView(
        children: [
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          for (int i = 0; i < statistics.length; i++)
            _statistic(context, statistics[i]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _statistic(BuildContext context, Statistic statistic) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              statistic.name,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ),
          StatisticWidget.of(statistic),
        ],
      ),
    );
  }
}

abstract class StatisticWidget<S extends Statistic> extends StatelessWidget {
  static const Widget _noData = Text('No Data');

  final S statistic;

  factory StatisticWidget.of(
    Statistic statistic,
  ) =>
      switch (statistic) {
        BooleanStatistic booleanStatistic => BooleanStatisticWidget(
            statistic: booleanStatistic,
          ),
        NumberStatistic numberStatistic => NumberStatisticWidget(
            statistic: numberStatistic,
          ),
        OprStatistic oprStatistic => OprStatisticWidget(
            statistic: oprStatistic,
          ),
        PieChartStatistic pieChartStatistic => PieChartStatisticWidget(
            statistic: pieChartStatistic,
          ),
        RadarStatistic radarStatistic => RadarStatisticWidget(
            statistic: radarStatistic,
          ),
        RankingPointsStatistic rankingPointsStatistic =>
          RankingPointsStatisticWidget(
            statistic: rankingPointsStatistic,
          ),
        StringStatistic stringStatistic => StringStatisticWidget(
            statistic: stringStatistic,
          ),
        WltStatistic wltStatistic => WltStatisticWidget(
            statistic: wltStatistic,
          ),
      } as StatisticWidget<S>;

  const StatisticWidget({
    super.key,
    required this.statistic,
  });

  String _formatNumber(double number) {
    if (number.toInt() == number) {
      return number.toStringAsFixed(0);
    }

    if (number == 0) {
      return '0';
    }

    double magnitude = number.abs();

    if (magnitude < 0.1) {
      return number.toStringAsPrecision(1);
    } else if (magnitude < 1) {
      return number.toStringAsFixed(2);
    } else if (magnitude < 10) {
      return number.toStringAsFixed(1);
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatNumberPrecise(double number) {
    if (number == 0) {
      return '0';
    }

    double magnitude = number.abs();

    if (magnitude < 0.01) {
      return number.toStringAsPrecision(1);
    } else if (magnitude < 10) {
      return number.toStringAsFixed(2);
    } else if (magnitude < 100) {
      return number.toStringAsFixed(1);
    } else {
      return number.toStringAsFixed(0);
    }
  }

  String _formatPercentage(double percent) {
    percent *= 100;

    if (percent >= 100) {
      return '100%';
    } else if (percent <= 0) {
      return '0%';
    }

    if (percent >= 99) {
      return '> 99%';
    } else if (percent <= 1) {
      return '< 1%';
    }

    return '${percent.toStringAsFixed(0)}%';
  }
}

class BooleanStatisticWidget extends StatisticWidget<BooleanStatistic> {
  const BooleanStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.percent == null) {
      return StatisticWidget._noData;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          dataMap: {
            'Yes': statistic.percent!,
            'No': 1 - statistic.percent!,
          },
          animationDuration: Duration.zero,
          chartType: ChartType.ring,
          chartRadius: MediaQuery.of(context).size.width * 0.5,
          colorList: const [
            Colors.green,
            Colors.red,
          ],
          initialAngleInDegree: 270,
          chartLegendSpacing: 24,
          legendOptions: const LegendOptions(showLegends: false),
          chartValuesOptions: const ChartValuesOptions(showChartValues: false),
        ),
        Text(
          _formatPercentage(statistic.percent!),
          style: Theme.of(context).textTheme.displaySmall,
        )
      ],
    );
  }
}

class NumberStatisticWidget extends StatisticWidget<NumberStatistic> {
  const NumberStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.mean == null) {
      return StatisticWidget._noData;
    }

    return Column(
      children: [
        Text(
          _formatNumber(statistic.mean!),
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Min ${_formatNumber(statistic.min!)}'),
            const SizedBox(width: 8),
            Text('Max ${_formatNumber(statistic.max!)}'),
            const SizedBox(width: 8),
            Text('Std Dev ${_formatNumber(statistic.stddev!)}'),
          ],
        ),
      ],
    );
  }
}

class OprStatisticWidget extends StatisticWidget<OprStatistic> {
  const OprStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.opr == null) {
      return StatisticWidget._noData;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('OPR:'),
            Text('DPR:'),
            Text('CCWM:'),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(_formatNumberPrecise(statistic.opr!)),
            Text(_formatNumberPrecise(statistic.dpr!)),
            Text(_formatNumberPrecise(statistic.ccwm!)),
          ],
        ),
      ],
    );
  }
}

class PieChartStatisticWidget extends StatisticWidget<PieChartStatistic> {
  static const List<Color> colors = [
    Colors.red,
    Colors.yellow,
    Colors.green,
    Colors.blue,
  ];

  const PieChartStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.slices == null) {
      return StatisticWidget._noData;
    }

    return PieChart(
      dataMap: statistic.slices!
          .map((key, value) => MapEntry(key, value.toDouble())),
      animationDuration: Duration.zero,
      chartType: ChartType.ring,
      chartRadius: MediaQuery.of(context).size.shortestSide * 0.5,
      colorList: colors,
      initialAngleInDegree: 270,
      chartLegendSpacing: 24,
      legendOptions: const LegendOptions(legendPosition: LegendPosition.bottom),
      chartValuesOptions: ChartValuesOptions(
        chartValueBackgroundColor: Theme.of(context).colorScheme.surface,
        chartValueStyle:
            Theme.of(context).textTheme.titleSmall ?? defaultChartValueStyle,
        decimalPlaces: 0,
      ),
    );
  }
}

class RadarStatisticWidget extends StatisticWidget<RadarStatistic> {
  const RadarStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.width * 0.7;
    return SizedBox(
      width: size,
      height: size,
      child: RadarChart(
        max: statistic.max,
        features: statistic.points.entries
            .map((e) => RadarChartPoint(label: e.key, value: e.value ?? 0))
            .toList(growable: false),
        graphColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        graphStrokeColor: Theme.of(context).colorScheme.primary,
        axisColor: Theme.of(context).colorScheme.onBackground,
        tickColor: Theme.of(context).colorScheme.onBackground,
        labelTextStyle: Theme.of(context).textTheme.titleSmall,
        tickSize: 5,
      ),
    );
  }
}

class RankingPointsStatisticWidget
    extends StatisticWidget<RankingPointsStatistic> {
  const RankingPointsStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.points == null) {
      return StatisticWidget._noData;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: statistic.points!.keys
              .map((e) => Text('$e:'))
              .toList(growable: false),
        ),
        const SizedBox(width: 8),
        Column(
          children: statistic.points!.values
              .map((e) => Text(e.toString()))
              .toList(growable: false),
        ),
      ],
    );
  }
}

class StringStatisticWidget extends StatisticWidget<StringStatistic> {
  const StringStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return Text(
      statistic.value ?? '-',
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }
}

class WltStatisticWidget extends StatisticWidget<WltStatistic> {
  const WltStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wins:'),
            Text('Losses:'),
            Text('Ties:'),
          ],
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            Text(statistic.wins.toString()),
            Text(statistic.losses.toString()),
            Text(statistic.ties.toString()),
          ],
        ),
      ],
    );
  }
}
