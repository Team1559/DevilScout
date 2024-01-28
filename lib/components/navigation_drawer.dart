import 'package:flutter/material.dart';

import '/pages/drive_team_scout_select.dart';
import '/pages/login.dart';
import '/pages/management.dart';
import '/pages/match_scout_select.dart';
import '/pages/pit_scout_select.dart';
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
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(vertical: 16, horizontal: 2.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Scout',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListTile(
                title: Text(
                  'Matches',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: const Icon(Icons.event),
                onTap: () => pushStatefulIfInactive<MatchSelectPageState>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MatchSelectPage(),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Pits',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: const Icon(Icons.assignment),
                onTap: () => pushStatefulIfInactive<PitSelectPageState>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PitSelectPage(),
                  ),
                ),
              ),
              ListTile(
                title: Text(
                  'Drive Team',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: const Icon(Icons.sports_esports),
                onTap: () =>
                    pushStatefulIfInactive<DriveTeamScoutSelectPageState>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DriveTeamScoutSelectPage(),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  'Analyze',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              ListTile(
                title: Text(
                  'Teams',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                leading: const Icon(Icons.query_stats),
                onTap: () {},
              ),
              if (User.current!.isAdmin)
                Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'Admin',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        'Manage Team ${Team.current!.number}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      leading: const Icon(Icons.manage_accounts),
                      onTap: () => pushStatelessIfInactive<ManagementPage>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ManagementPage(),
                        ),
                      ),
                    ),
                  ],
                ),
              const Spacer(),
              Column(
                children: [
                  Text(
                    User.current!.fullName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    Team.current!.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilledButton.icon(
                        icon: const Icon(Icons.settings),
                        label: const Text('Settings'),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.grey[700]),
                        ),
                        onPressed: () =>
                            pushStatefulIfInactive<SettingsPageState>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SettingsPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      FilledButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: const ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(Colors.red),
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
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void pushStatefulIfInactive<STATE extends State>(
      BuildContext context, MaterialPageRoute<STATE> route) {
    STATE? parent = context.findAncestorStateOfType<STATE>();
    if (parent == null) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.pop(context);
    }
  }

  void pushStatelessIfInactive<WIDGET extends Widget>(
      BuildContext context, MaterialPageRoute<WIDGET> route) {
    WIDGET? parent = context.findAncestorWidgetOfExactType<WIDGET>();
    if (parent == null) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.pop(context);
    }
  }
}
