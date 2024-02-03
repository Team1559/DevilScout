import 'package:devil_scout/pages/select_team.dart';
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

class MenuScaffold extends StatefulWidget {
  final Widget? body;
  final String? title;
  final List<Widget>? actions;

  const MenuScaffold({
    super.key,
    this.body,
    this.title,
    this.actions,
  });

  @override
  State<MenuScaffold> createState() => _MenuScaffoldState();
}

class _MenuScaffoldState extends State<MenuScaffold>
    with SingleTickerProviderStateMixin {
  static const Duration fadeDuration = Duration(milliseconds: 200);
  static const Duration iconDuration = Duration(milliseconds: 250);

  late final AnimationController iconAnimation = AnimationController(
    duration: iconDuration,
    vsync: this,
  );

  bool menuVisible = false;

  Widget transitionBuilder(Widget child, Animation<double> animation) =>
      FadeTransition(
        opacity: animation,
        child: child,
      );

  @override
  void dispose() {
    super.dispose();
    iconAnimation.dispose();
  }

  void showMenu() {
    if (menuVisible) return;

    setState(() => menuVisible = true);
    iconAnimation.animateTo(1);
  }

  void hideMenu() {
    if (!menuVisible) return;

    setState(() => menuVisible = false);
    iconAnimation.animateBack(0);
  }

  void toggleMenu() {
    if (menuVisible) {
      hideMenu();
    } else {
      showMenu();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: AnimatedSwitcher(
          duration: fadeDuration,
          transitionBuilder: transitionBuilder,
          child: Text(
            menuVisible ? '' : widget.title ?? '',
            key: menuVisible ? const Key('Menu Title') : null,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        leading: IconButton(
          onPressed: toggleMenu,
          icon: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: iconAnimation,
          ),
        ),
        actions: widget.actions,
        leadingWidth: 72,
      ),
      body: AnimatedSwitcher(
        duration: fadeDuration,
        transitionBuilder: transitionBuilder,
        child: menuVisible
            ? Builder(
                builder: navigationMenu,
                key: const Key('NavigationMenu'),
              )
            : widget.body,
      ),
    );
  }

  Widget navigationMenu(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 18,
      ),
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
              onTap: pushStatefulIfInactive<TeamAnalysisSelectPageState>(
                context: context,
                builder: (context) => const TeamAnalysisSelectPage(),
              ),
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
    );
  }

  Widget bottom(BuildContext context) {
    return Column(
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
                          color: Theme.of(context).colorScheme.onPrimary,
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
    );
  }

  Widget section({
    required BuildContext context,
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8,
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
    if (parent != null) {
      return hideMenu;
    }

    return () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: builder),
        );
  }

  void Function() pushStatelessIfInactive<WIDGET extends Widget>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) {
    WIDGET? parent = context.findAncestorWidgetOfExactType<WIDGET>();
    if (parent != null) {
      return hideMenu;
    }

    return () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: builder),
        );
  }
}
