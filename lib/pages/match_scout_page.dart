import 'package:flutter/material.dart';

class MatchScoutPage extends StatefulWidget {
  const MatchScoutPage({Key? key}) : super(key: key);

  @override
  State<MatchScoutPage> createState() => _MatchScoutPageState();
}

class _MatchScoutPageState extends State<MatchScoutPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        body: Center(
      child: Text('This is the Match Scout Page'),
    ));
  }
}
