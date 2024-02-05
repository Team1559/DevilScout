import 'package:flutter/material.dart';

import '/components/radar_chart.dart';
import '/server/analysis.dart';

class AnalysisDisplay extends StatefulWidget {
  final TeamStatistics data;

  const AnalysisDisplay({super.key, required this.data});

  @override
  State<AnalysisDisplay> createState() => _AnalysisDisplayState();
}

class _AnalysisDisplayState extends State<AnalysisDisplay> {
  final PageController controller = PageController();

  int currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.only(bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: PageView(
              controller: controller,
              onPageChanged: (page) => setState(() => currentPage = page),
              children: List.generate(widget.data.pages.length, (index) {
                StatisticsPage page = widget.data.pages[index];
                return _StatisticsDisplayPage(
                  title: page.title,
                  statistics: page.statistics,
                );
              }),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              FilledButton(
                onPressed: currentPage == 0 ? null : _previousPage,
                child: const Text('Previous'),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: currentPage == widget.data.pages.length - 1
                    ? null
                    : _nextPage,
                child: const Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (currentPage != widget.data.pages.length - 1) {
      setState(() => currentPage++);
      _gotoPage();
    }
  }

  void _previousPage() {
    if (currentPage != 0) {
      setState(() => currentPage--);
      _gotoPage();
    }
  }

  void _gotoPage() {
    controller.animateToPage(
      currentPage,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }
}

class _StatisticsDisplayPage extends StatelessWidget {
  final String title;
  final List<Statistic> statistics;

  const _StatisticsDisplayPage({required this.title, required this.statistics});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
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
              statistic(context, statistics[i]),
          ],
        ),
      ),
    );
  }

  Widget statistic(BuildContext context, Statistic statistic) {
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
    return const Text('This is a BooleanStatistic');
  }
}

class NumberStatisticWidget extends StatisticWidget<NumberStatistic> {
  const NumberStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return const Text('This is a NumberStatistic');
  }
}

class OprStatisticWidget extends StatisticWidget<OprStatistic> {
  const OprStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return const Text('This is a OprStatistic');
  }
}

class PieChartStatisticWidget extends StatisticWidget<PieChartStatistic> {
  const PieChartStatisticWidget({super.key, required super.statistic});

  @override
  Widget build(BuildContext context) {
    return const Text('This is a PieChartStatistic');
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
        features: statistic.points
            .map((e) => RadarChartPoint(label: e.label, value: e.value ?? 0))
            .toList(growable: false),
        graphColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        graphStrokeColor: Theme.of(context).colorScheme.primary,
        axisColor: Colors.white60,
        tickColor: Colors.white54,
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
    return const Text('This is a RankingPointsStatistic');
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
    return const Text('This is a WtlStatistic');
  }
}
