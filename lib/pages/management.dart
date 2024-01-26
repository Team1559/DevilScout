import 'package:flutter/material.dart';

import '/components/large_text_field.dart';
import '/components/navigation_drawer.dart';
import '/components/snackbar.dart';
import '/server/server.dart';
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
                  itemBuilder: (context, index) {
                    User user = User.allUsers[index];
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
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: user.isAdmin
                                ? null
                                : () => serverDeleteUser(id: user.id)
                                        .then((response) {
                                      if (response.success) {
                                        setState(
                                            () => User.allUsers.remove(user));
                                        displaySnackbar(context,
                                            'User "${user.fullName}" deleted');
                                      } else {
                                        displaySnackbar(
                                          context,
                                          response.message ??
                                              'An error occurred',
                                        );
                                      }
                                    }),
                          ),
                        ],
                      ),
                    );
                  },
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
                  builder: (context) => const UserAddDialog(),
                  fullscreenDialog: true,
                ),
              ).whenComplete(() => setState(() {})),
              icon: const Icon(Icons.add),
              label: const Text('Add User'),
            ),
          ),
        ],
      );
}

class UserAddDialog extends StatefulWidget {
  const UserAddDialog({super.key});

  @override
  State<UserAddDialog> createState() => _UserAddDialogState();
}

class _UserAddDialogState extends State<UserAddDialog> {
  final nameController = TextEditingController();

  final usernameController = TextEditingController();

  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.addListener(_listener);
    usernameController.addListener(_listener);
    passwordController.addListener(_listener);
    confirmPasswordController.addListener(_listener);
  }

  void _listener() => setState(() {});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('New User'),
          centerTitle: true,
          actions: [
            IconButton.filled(
              onPressed: _areFieldsValid() ? () => _tryAddUser(context) : null,
              icon: const Icon(Icons.add),
              color: Colors.white,
            ),
            const SizedBox(width: 4),
          ],
        ),
        body: SafeArea(
          minimum: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                LargeTextField(
                  controller: nameController,
                  hintText: 'Full Name',
                ),
                LargeTextField(
                  controller: usernameController,
                  hintText: 'Username',
                ),
                LargeTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),
                LargeTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
      );

  bool _areFieldsValid() {
    String fullName = nameController.text;
    if (fullName.isEmpty) return false;

    String username = usernameController.text;
    if (username.isEmpty) return false;

    String password = passwordController.text;
    if (password != confirmPasswordController.text) return false;
    if (password.length < 8) return false;

    return true;
  }

  Future<void> _tryAddUser(BuildContext context) async {
    String password = passwordController.text;
    String username = usernameController.text;
    String fullName = nameController.text;

    if (username.toLowerCase().contains(password) ||
        fullName.toLowerCase().contains(password.toLowerCase())) {
      displaySnackbar(context, 'Password should not contain name');
      return;
    }

    ServerResponse<User> response = await serverCreateUser(
      fullName: nameController.text,
      username: usernameController.text,
      password: passwordController.text,
    );
    if (!context.mounted) return;

    if (response.success) {
      User.allUsers.add(response.value!);
      Navigator.of(context).pop();
    } else {
      displaySnackbar(
        context,
        response.message ?? 'An error occurred',
      );
    }
  }
}
