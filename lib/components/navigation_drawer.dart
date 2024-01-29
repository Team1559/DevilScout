import 'package:flutter/material.dart';

import '/pages/login.dart';
import '/pages/manage.dart';
import '/pages/select_drive_team.dart';
import '/pages/select_match.dart';
import '/pages/select_pit.dart';
import '/pages/settings.dart';
import '/server/auth.dart';
import '/server/session_file.dart';
import '/server/teams.dart';
import '/server/users.dart';

class NavDrawer extends StatelessWidget {
  const NavDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: double.infinity,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            'Devil Scout',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              section(context: context, title: 'Scout', children: [
                menuItem(
                  context: context,
                  title: 'Matches',
                  icon: const Icon(Icons.event),
                  onTap: pushStatefulIfInactive<MatchSelectPageState>(
                    context: context,
                    builder: (context) => const MatchSelectPage(),
                  ),
                ),
                menuItem(
                  context: context,
                  title: 'Pits',
                  icon: const Icon(Icons.assignment),
                  onTap: pushStatefulIfInactive<PitSelectPageState>(
                    context: context,
                    builder: (context) => const PitSelectPage(),
                  ),
                ),
                menuItem(
                  context: context,
                  title: 'Drive Team',
                  icon: const Icon(Icons.sports_esports),
                  onTap: pushStatefulIfInactive<DriveTeamSelectPageState>(
                    context: context,
                    builder: (context) => const DriveTeamSelectPage(),
                  ),
                ),
              ]),
              section(context: context, title: 'Analyze', children: [
                menuItem(
                  context: context,
                  title: 'Teams',
                  icon: const Icon(Icons.query_stats),
                  onTap: () {},
                ),
              ]),
              if (User.current!.isAdmin)
                section(context: context, title: 'Admin', children: [
                  menuItem(
                    context: context,
                    title: 'Manage Team ${Team.current!.number}',
                    icon: const Icon(Icons.manage_accounts),
                    onTap: pushStatelessIfInactive<ManagementPage>(
                      context: context,
                      builder: (context) => const ManagementPage(),
                    ),
                  ),
                ]),
              const Spacer(),
              bottom(context),
            ],
          ),
        ),
      ),
    );
  }

  Padding bottom(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                User.current!.fullName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.left,
              ),
              const SizedBox(width: 2),
              if (User.current!.isAdmin)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Admin',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${Team.current!.number} | ${Team.current!.name}',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.left,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.settings),
                style: ButtonStyle(
                  minimumSize: const MaterialStatePropertyAll(
                    Size(80, 48),
                  ),
                  maximumSize: const MaterialStatePropertyAll(
                    Size(double.infinity, 48),
                  ),
                  shape: const MaterialStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                  ),
                  backgroundColor: MaterialStatePropertyAll(
                    Theme.of(context).colorScheme.surface,
                  ),
                ),
                onPressed: pushStatefulIfInactive<SettingsPageState>(
                  context: context,
                  builder: (context) => const SettingsPage(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                  onPressed: () {
                    serverLogout().whenComplete(saveSession);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget section({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 10,
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget menuItem({
    required BuildContext context,
    required String title,
    required Icon icon,
    required void Function() onTap,
  }) {
    return ListTile(
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      leading: icon,
      onTap: onTap,
    );
  }

  void Function() pushStatefulIfInactive<STATE extends State>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    STATE? parent = context.findAncestorStateOfType<STATE>();
    if (parent == null) {
      return () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: builder),
          );
    } else {
      return Navigator.of(context).pop;
    }
  }

  void Function() pushStatelessIfInactive<WIDGET extends Widget>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    WIDGET? parent = context.findAncestorWidgetOfExactType<WIDGET>();
    if (parent == null) {
      return () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: builder),
          );
    } else {
      return Navigator.of(context).pop;
    }
  }
}
