import 'package:flutter/material.dart';

import '/server/events.dart';

class TeamCard extends StatelessWidget {
  final int teamNum;
  final Color? color;
  final String? label;
  final void Function()? onTap;

  const TeamCard({
    super.key,
    required this.teamNum,
    this.color,
    this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    FrcTeam? team = FrcTeam.currentEventTeams
        .where((team) => team.number == teamNum)
        .firstOrNull;
    return Card(
      color: color,
      child: ListTile(
        minLeadingWidth: 10,
        leading: label == null
            ? null
            : Text(
                label!,
                style: Theme.of(context).textTheme.titleSmall,
              ),
        title: Text(
          team?.name ?? '???',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: team == null
            ? null
            : Text(
                team.location,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.fade,
                style: Theme.of(context).textTheme.labelMedium,
              ),
        trailing: Text(
          teamNum.toString(),
          style: Theme.of(context).textTheme.titleSmall,
        ),
        onTap: onTap,
      ),
    );
  }
}
