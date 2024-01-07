import 'package:flutter/material.dart';

import '/pages/drive_team_feedback_select.dart';
import '/pages/login.dart';
import '/pages/match_scout_select.dart';
import '/pages/settings.dart';
import '/pages/team_select.dart';
import '/pages/management.dart';
import '/server/auth.dart';
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
            ExpansionPanelList.radio(
              materialGapSize: 2,
              expandedHeaderPadding: EdgeInsets.zero,
              dividerColor: Colors.grey,
              children: [
                ExpansionPanelRadio(
                  value: 'Scout',
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) => const ListTile(
                    title: Text('Scout'),
                    leading: Icon(Icons.image),
                  ),
                  body: Column(
                    children: [
                      ListTile(
                        title: const Text('Matches'),
                        leading: const Icon(Icons.abc),
                        onTap: () {
                          MatchSelectPageState? parent = context
                              .findAncestorStateOfType<MatchSelectPageState>();
                          if (parent == null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MatchSelectPage(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Pits'),
                        leading: const Icon(Icons.abc),
                        onTap: () {
                          EventTeamSelectPageState? parent =
                              context.findAncestorStateOfType<
                                  EventTeamSelectPageState>();
                          if (parent == null) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const EventTeamSelectPage(),
                              ),
                            );
                          } else {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      if (User.currentUser!.isAdmin)
                        ListTile(
                          title: const Text('Drive Team'),
                          leading: const Icon(Icons.abc),
                          onTap: () {
                            DriveTeamFeedbackSelectPageState? parent =
                                context.findAncestorStateOfType<
                                    DriveTeamFeedbackSelectPageState>();
                            if (parent == null) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DriveTeamFeedbackSelectPage(),
                                ),
                              );
                            } else {
                              Navigator.pop(context);
                            }
                          },
                        ),
                    ],
                  ),
                ),
                ExpansionPanelRadio(
                  value: 'Analyze',
                  canTapOnHeader: true,
                  headerBuilder: (context, isExpanded) => const ListTile(
                    title: Text('Analyze'),
                    leading: Icon(Icons.image),
                  ),
                  body: Column(
                    children: [
                      ListTile(
                        onTap: () {},
                        title: const Text('Teams'),
                        leading: const Icon(Icons.abc),
                      )
                    ],
                  ),
                ),
              ],
            ),
            if (User.currentUser!.isAdmin)
              ListTile(
                title: Text('Manage Team ${Team.currentTeam!.number}'),
                leading: const Icon(Icons.image),
                onTap: () {
                  ManagementPageState? parent =
                      context.findAncestorStateOfType<ManagementPageState>();
                  if (parent == null) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ManagementPage(),
                      ),
                    );
                  } else {
                    Navigator.pop(context);
                  }
                },
              ),
            const Spacer(),
            Text(
              User.currentUser!.fullName,
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            Text(
              Team.currentTeam!.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsPage(),
                    ),
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.grey[700]),
                  ),
                  child: const Icon(Icons.settings),
                ),
                const SizedBox(width: 20),
                FilledButton.icon(
                  onPressed: () {
                    serverLogout();
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Log Out'),
                  style: const ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll(Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
