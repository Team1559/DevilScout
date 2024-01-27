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
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 32, horizontal: 2.0),
        child: Column(
          children: [
            Text(
              'DevilScout',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, 'Scout'),
                ListTile(
                  title: const Text('Matches'),
                  leading: const Icon(Icons.event),
                  onTap: () => pushIfInactive<MatchSelectPageState>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MatchSelectPage(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Pits'),
                  leading: const Icon(Icons.assignment),
                  onTap: () => pushIfInactive<PitSelectPageState>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PitSelectPage(),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text('Drive Team'),
                  leading: const Icon(Icons.sports_esports),
                  onTap: () => pushIfInactive<DriveTeamScoutSelectPageState>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DriveTeamScoutSelectPage(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(context, 'Analyze'),
                ListTile(
                  title: const Text('Teams'),
                  leading: const Icon(Icons.query_stats),
                  onTap: () {},
                ),
              ],
            ),
            const Spacer(),
            if (User.current!.isAdmin)
              ListTile(
                title: Text('Manage Team ${Team.current!.number}'),
                leading: const Icon(Icons.manage_accounts),
                onTap: () => pushIfInactive<ManagementPageState>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ManagementPage(),
                  ),
                ),
              ),
            Text(
              User.current!.fullName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              Team.current!.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  icon: const Icon(Icons.settings),
                  label: const Text('Settings'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.grey[700]),
                  ),
                  onPressed: () => pushIfInactive<SettingsPageState>(
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
        ),
      ),
    );
  }

  void pushIfInactive<STATE extends State>(
      BuildContext context, MaterialPageRoute<STATE> route) {
    STATE? parent = context.findAncestorStateOfType<STATE>();
    if (parent == null) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.pop(context);
    }
  }

  Widget _header(BuildContext context, String text) => Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      );
}
