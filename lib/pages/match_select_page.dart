import 'package:flutter/material.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({Key? key}) : super(key: key);

  @override
  State<MatchSelectPage> createState() => _MatchSelectPageState();
}

class _MatchSelectPageState extends State<MatchSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
      title: const Text("DevilScout"),
      centerTitle: true,
    ));
  }
}
