import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/server/events.dart';
import '/server/teams.dart';
import '/theme.dart';

class MatchCard extends StatelessWidget {
  static final DateFormat timeFormat = DateFormat('EEEE\nh:mm a');

  final EventMatch match;
  final void Function(EventMatch)? onTap;
  final bool transparency;

  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.transparency = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(match),
      child: Opacity(
        opacity: transparency && match.completed ? 0.5 : 1,
        child: Card(
          child: Column(
            children: [
              ListTile(
                title: Text(
                  match.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (match.containsTeam(Team.current!.number))
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.star,
                          color: match.red.contains(Team.current!.number)
                              ? Theme.of(context).colorScheme.frcRed
                              : Theme.of(context).colorScheme.frcBlue,
                        ),
                      ),
                    Text(
                      timeFormat.format(match.time),
                      textAlign: TextAlign.end,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _allianceView(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Table _allianceView(BuildContext context) {
    return Table(
      children: [
        TableRow(
          children: List.generate(
            match.red.length,
            (index) => _teamRect(
              context: context,
              match: match,
              index: index,
              isRed: true,
            ),
          ),
        ),
        TableRow(
          children: List.generate(
            match.blue.length,
            (index) => _teamRect(
              context: context,
              match: match,
              index: index,
              isRed: false,
            ),
          ),
        ),
      ],
    );
  }

  Widget _teamRect({
    required BuildContext context,
    required EventMatch match,
    required int index,
    required bool isRed,
  }) {
    List<int> alliance = isRed ? match.red : match.blue;
    return Padding(
      padding: EdgeInsets.only(
        left: index == 0 ? 0 : 1,
        right: index == alliance.length - 1 ? 0 : 1,
        top: isRed ? 0 : 1,
        bottom: isRed ? 1 : 0,
      ),
      child: Container(
        color: isRed
            ? Theme.of(context).colorScheme.frcRed
            : Theme.of(context).colorScheme.frcBlue,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Text(
          '${alliance[index]}',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ),
    );
  }
}
