import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/user_edit_dialog.dart';
import '/server/users.dart';
import '/settings.dart';

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
    serverGetCurrentUser();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Builder(builder: (context) {
        if (settings == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return ListView(
          children: [
            ListTile(
              title: const Text('Edit User'),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  isDismissible: true,
                  builder: (context) => UserEditDialog(
                    user: User.current,
                    showAdmin: User.current!.isAdmin,
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Use Device Theme'),
              trailing: Checkbox(
                value: settings!.theme == ThemeMode.system,
                onChanged: (value) => setState(() {
                  settings!.theme =
                      value! ? ThemeMode.system : ThemeModeHelper.current();
                }),
              ),
            ),
            Opacity(
              opacity: settings!.theme == ThemeMode.system ? .5 : 1,
              child: ListTile(
                title: const Text('Dark Mode'),
                trailing: Checkbox(
                  value: settings!.theme.resolve() == ThemeMode.dark,
                  onChanged: settings!.theme == ThemeMode.system
                      ? null
                      : (value) => setState(() {
                            settings!.theme =
                                value! ? ThemeMode.dark : ThemeMode.light;
                          }),
                ),
              ),
            ),
          ],
        );
      }),
      drawer: const NavDrawer(),
    );
  }
}
