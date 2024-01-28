import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/user_edit_dialog.dart';
import '/server/teams.dart';
import '/server/users.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage'),
        bottom: PreferredSize(
          preferredSize: Size.zero,
          child: Text(
            Team.current!.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
      drawer: const NavDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              Text(
                'Team Roster',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10.0),
              const RosterPanel(),
            ],
          ),
        ),
      ),
    );
  }
}

class RosterPanel extends StatefulWidget {
  const RosterPanel({super.key});

  @override
  State<RosterPanel> createState() => _RosterPanelState();
}

class _RosterPanelState extends State<RosterPanel> {
  @override
  void initState() {
    super.initState();
    serverGetUsers().whenComplete(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: User.allUsers.length,
                  itemBuilder: (context, index) =>
                      _userCard(User.allUsers[index], context),
                ),
              ),
            ),
          ),
          FilledButton.icon(
            style: const ButtonStyle(
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                  ),
                ),
              ),
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              isDismissible: true,
              builder: (context) => const UserEditDialog(showAdmin: false),
            ).then((user) {
              setState(() {
                if (user != null) {
                  User.allUsers.add(user);
                }
              });
            }),
            icon: const Icon(Icons.add),
            label: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Card _userCard(User user, BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          user.fullName,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        subtitle: Text(
          user.username,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: user.isAdmin
              ? null
              : () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    isDismissible: true,
                    builder: (context) => UserEditDialog(
                      user: user,
                      showAdmin: true,
                    ),
                  ).then((user) {
                    setState(() {
                      if (user == null) {
                        User.allUsers.remove(user);
                      }
                    });
                  }),
        ),
      ),
    );
  }
}
