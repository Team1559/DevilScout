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
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: ListView(
        children: [
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          for (int i = 0; i < statistics.length; i++)
            _statistic(context, statistics[i]),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _statistic(BuildContext context, Statistic statistic) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            statistic.name,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        StatisticWidget.of(statistic),
      ],
    );
  }
}

abstract class StatisticWidget<S extends Statistic> extends StatelessWidget {
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
}

class BooleanStatisticWidget extends StatisticWidget<BooleanStatistic> {
  const BooleanStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    if (statistic.percent == null) {
      return const Text('No Data');
    }

    return PieChart(
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
      legendOptions: const LegendOptions(
        legendPosition: LegendPosition.left,
      ),
      chartValuesOptions: ChartValuesOptions(
        chartValueBackgroundColor: Theme.of(context).colorScheme.surface,
        chartValueStyle:
            Theme.of(context).textTheme.titleSmall ?? defaultChartValueStyle,
      ),
      formatChartValues: (d) {
        if (d <= 0) {
          return '0%';
        } else if (d < 0.001) {
          return '< 0.1%';
        } else if (d < 0.01) {
          return '${(d * 100).toStringAsFixed(1)}%';
        }

        if (d >= 1) {
          return '100%';
        } else if (d > 0.999) {
          return '> 99.9%';
        } else if (d > 0.99) {
          return '${(d * 100).toStringAsFixed(1)}%';
        }

        return '${(d * 100).toStringAsFixed(0)}%';
      },
    );
  }
}

class NumberStatisticWidget extends StatisticWidget<NumberStatistic> {
  const NumberStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          statistic.mean?.toString() ?? '-',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text(
          'Std dev ${statistic.stddev ?? '-'}  Max: ${statistic.max ?? '-'}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class OprStatisticWidget extends StatisticWidget<OprStatistic> {
  const OprStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
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
          children: [
            Text(_formatValue(statistic.opr)),
            Text(_formatValue(statistic.dpr)),
            Text(_formatValue(statistic.ccwm)),
          ],
        ),
      ],
    );
  }

  String _formatValue(double? value) {
    if (value == null) return '-';
    return value.toStringAsPrecision(3);
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
      return const Text('No Data');
    }

    return PieChart(
      dataMap: statistic.slices!
          .map((key, value) => MapEntry(key, value.toDouble())),
      animationDuration: Duration.zero,
      chartType: ChartType.ring,
      chartRadius: MediaQuery.of(context).size.width * 0.5,
      colorList: colors,
      initialAngleInDegree: 270,
      chartLegendSpacing: 24,
      legendOptions: const LegendOptions(
        legendPosition: LegendPosition.left,
      ),
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
      return const Text('No Data');
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: statistic.points!.keys
              .map((e) => Text('$e: '))
              .toList(growable: false),
        ),
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
    return Text(statistic.value ?? '-');
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
