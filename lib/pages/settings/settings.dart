import 'package:flutter/material.dart';

import '/components/logout.dart';
import '/components/menu_scaffold.dart';
import '/components/user_edit_dialog.dart';
import '/pages/settings/about.dart';
import '/pages/settings/technical.dart';
import '/server/users.dart';
import '/settings.dart';
import '/theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => SettingsPageState();
}

class SettingsPageState extends State<SettingsPage> {
  AppSettings? settings;

  @override
  void initState() {
    super.initState();
    serverGetCurrentUser().then(detectLogout());
    getSettings().then((value) {
      setState(() => settings = value);
      settings!.addListener(_listener);
    });
  }

  void _listener() {
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    settings?.removeListener(_listener);
  }

  @override
  Widget build(BuildContext context) {
    detectDelayedLogout(context);
    return MenuScaffold(
      title: 'Settings',
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Builder(builder: (context) {
          if (settings == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              FilledButton.icon(
                label: const Text('Edit User'),
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => UserEditDialog(
                      user: User.current,
                      showAdmin: User.current.isAdmin,
                    ),
                  );
                },
              ),
              ListTile(
                title: Text(
                  'Use Device Theme',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                trailing: Checkbox(
                  value: settings!.theme == ThemeMode.system,
                  onChanged: (value) => setState(() {
                    settings!.theme =
                        value! ? ThemeMode.system : ThemeModeHelper.platform();
                  }),
                ),
                onTap: () => setState(
                  () {
                    settings!.theme = settings!.theme != ThemeMode.system
                        ? ThemeMode.system
                        : ThemeModeHelper.platform();
                  },
                ),
              ),
              Opacity(
                opacity: settings!.theme == ThemeMode.system ? .5 : 1,
                child: ListTile(
                  title: Text(
                    'Dark Mode',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  trailing: Checkbox(
                    value: settings!.theme.resolve() == ThemeMode.dark,
                    onChanged: settings!.theme == ThemeMode.system
                        ? null
                        : (value) => setState(() {
                              settings!.theme =
                                  value! ? ThemeMode.dark : ThemeMode.light;
                            }),
                  ),
                  onTap: settings!.theme == ThemeMode.system
                      ? null
                      : () => setState(
                            () {
                              settings!.theme =
                                  settings!.theme != ThemeMode.dark
                                      ? ThemeMode.dark
                                      : ThemeMode.light;
                            },
                          ),
                ),
              ),
              ListTile(
                title: Text(
                  'About',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                ),
              ),
              ListTile(
                title: Text(
                  'Technical',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TechnicalPage()),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
