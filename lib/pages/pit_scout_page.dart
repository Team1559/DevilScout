import 'package:flutter/material.dart';

class PitScoutPage extends StatefulWidget {
  const PitScoutPage({Key? key}) : super(key: key);

  @override
  State<PitScoutPage> createState() => _PitScoutPageState();
}

class _PitScoutPageState extends State<PitScoutPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('This is the Pit Scout Page'),
    ));
  }
}
