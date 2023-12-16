import 'package:flutter/material.dart';

import '/pages/login_page.dart';
import '/pages/match_select_page.dart';
import '/pages/settings_page.dart';
import '/server/auth.dart';
import '/server/teams.dart';
import '/server/users.dart';

class MyNavigationDrawer extends StatelessWidget {
  const MyNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        minimum: const EdgeInsets.symmetric(vertical: 32),
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
                        onTap: () {},
                      ),
                      if (User.currentUser!.accessLevel >= AccessLevel.admin)
                        ListTile(
                          title: const Text('Drive Team'),
                          leading: const Icon(Icons.abc),
                          onTap: () {},
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
                if (User.currentUser!.accessLevel >= AccessLevel.user)
                  ExpansionPanelRadio(
                    value: 'Manage',
                    canTapOnHeader: true,
                    headerBuilder: (context, isExpanded) => const ListTile(
                      title: Text('Manage'),
                      leading: Icon(Icons.image),
                    ),
                    body: Column(
                      children: [
                        ListTile(
                          onTap: () {},
                          title: const Text('Test'),
                          leading: const Icon(Icons.abc),
                        )
                      ],
                    ),
                  ),
              ],
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
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
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
