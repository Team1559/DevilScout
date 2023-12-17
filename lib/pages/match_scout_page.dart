import 'package:flutter/material.dart';

import '/server/events.dart';
import '/components/navigation_drawer.dart';

class MatchScoutPage extends StatefulWidget {
  final EventMatch match;
  final int team;

  const MatchScoutPage({Key? key, required this.match, required this.team})
      : super(key: key);

  @override
  State<MatchScoutPage> createState() => _MatchScoutPageState();
}

class _MatchScoutPageState extends State<MatchScoutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text('Team ${widget.team}'),
            Text(
              widget.match.name,
              style: Theme.of(context).textTheme.labelSmall,
            )
          ],
        ),
        leadingWidth: 120,
        leading: Builder(builder: (context) {
          return Row(
            children: [
              IconButton(
                onPressed: Navigator.of(context).maybePop,
                icon: const Icon(Icons.arrow_back),
              ),
              IconButton(
                onPressed: Scaffold.of(context).openDrawer,
                icon: const Icon(Icons.menu),
              ),
            ],
          );
        }),
      ),
      body: const Center(
        child: Text('This is the Match Scout Page'),
      ),
      drawer: const NavDrawer(),
    );
  }
}
