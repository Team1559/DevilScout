import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/user_edit_dialog.dart';
import '/server/users.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => ManagementPageState();
}

class ManagementPageState extends State<ManagementPage> {
  @override
  void initState() {
    super.initState();
    serverGetUsers().whenComplete(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
      ),
      drawer: const NavDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
          child: Column(
            children: [
              Text(
                "Team Roster",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10.0),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    width: 2.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                height: MediaQuery.of(context).size.height * 0.5,
                child: _usersPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column _usersPanel() => Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: User.allUsers.length,
                  itemBuilder: (context, index) =>
                      _userCard(User.allUsers[index], context),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserEditDialog(),
                  fullscreenDialog: true,
                ),
              ).then((user) {
                if (user == null) return;
                setState(() {
                  User.allUsers.add(user);
                });
              }),
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
            ),
          ),
        ],
      );

  Card _userCard(User user, BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 2.0,
      child: Row(
        children: [
          Expanded(
            child: ListTile(
              title: Text(user.fullName),
              subtitle: Text(user.username),
            ),
          ),
          if (!user.isAdmin)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UserEditDialog(user: user),
                    fullscreenDialog: true),
              ).then((user) {
                setState(() {
                  if (user == null) {
                    User.allUsers.remove(user);
                  }
                });
              }),
            ),
        ],
      ),
    );
  }
}
