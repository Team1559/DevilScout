import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/server/events.dart';
import '/server/teams.dart';
import 'match_scout_page.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({Key? key}) : super(key: key);

  @override
  State<MatchSelectPage> createState() => _MatchSelectPageState();
}

class _MatchSelectPageState extends State<MatchSelectPage> {
  @override
  void initState() {
    super.initState();

    if (Team.currentTeam!.hasEventKey) {
      Future.wait([
        serverGetCurrentEvent(),
        serverGetCurrentEventTeamList(),
        serverGetCurrentEventSchedule(),
      ]).whenComplete(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Select Match'),
            Text(
              Event.currentEvent?.name ?? '',
              style: Theme.of(context).textTheme.labelSmall,
            )
          ],
        ),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: EventMatch.currentEventSchedule.length,
        itemBuilder: _matchCard,
      ),
    );
  }

  Widget _matchCard(BuildContext context, int index) {
    EventMatch match = EventMatch.currentEventSchedule[index];
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            Text(match.name),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Visibility(
                visible: match.containsCurrentTeam(),
                maintainSize: true,
                maintainState: true,
                maintainAnimation: true,
                child: const Icon(Icons.star),
              ),
            ),
            Text(DateFormat('h:mm a').format(match.time)),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Table(
                children: [
                  TableRow(
                    children: List.generate(
                      match.blue.length,
                      (index) => _teamButton(
                        context: context,
                        match: match,
                        index: index,
                        isRed: false,
                      ),
                    ),
                  ),
                  TableRow(
                    children: List.generate(
                      match.red.length,
                      (index) => _teamButton(
                        context: context,
                        match: match,
                        index: index,
                        isRed: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teamButton({
    required BuildContext context,
    required EventMatch match,
    required int index,
    required bool isRed,
  }) {
    List<int> alliance = isRed ? match.red : match.blue;
    int team = alliance[index];

    double leftPadding = index == 0 ? 0 : 1;
    double rightPadding = index == alliance.length - 1 ? 0 : 1;
    double topPadding = isRed ? 1 : 0;
    double bottomPadding = isRed ? 0 : 1;

    return GestureDetector(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
            leftPadding, topPadding, rightPadding, bottomPadding),
        child: Container(
          color: isRed ? Colors.red[800] : Colors.blue[800],
          padding: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          child: Text('$team'),
        ),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const MatchScoutPage(),
        ),
      ),
    );
  }
}
