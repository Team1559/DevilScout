import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('This is the Statistics Page'),
    ));
  }
}
