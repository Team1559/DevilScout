import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/snackbar.dart';
import '/components/large_text_field.dart';
import '/server/users.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => ManagementPageState();
}

class ManagementPageState extends State<ManagementPage> {
  late Future<bool> futureUsers;
  late List<User> users;

  @override
  void initState() {
    super.initState();
    futureUsers = serverGetUsers().then((response) {
      if (response.success) {
        users = List.of(response.value!, growable: true);
      }
      return response.success;
    });
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

  Column _usersPanel() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Scrollbar(
              child: FutureBuilder(
                future: futureUsers,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  } else if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      User user = users[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2.0,
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: ListTile(
                                title: Text(user.fullName),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => serverDeleteUser(id: user.id)
                                  .then((response) {
                                if (response.success) {
                                  setState(() => users.remove(user));
                                  displaySnackbar(context,
                                      'User "${user.fullName}" deleted');
                                } else {
                                  displaySnackbar(
                                    context,
                                    response.message ?? 'An error occurred',
                                  );
                                }
                              }),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
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
            onPressed: () {
              final nameController = TextEditingController();
              final usernameController = TextEditingController();
              final passwordController = TextEditingController();
              final confirmPasswordController = TextEditingController();
              bool isAdmin = false;

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return FractionallySizedBox(
                        heightFactor: 0.8,
                        child: AlertDialog(
                          backgroundColor:
                              Theme.of(context).colorScheme.background,
                          title: Text('Add User',
                              style: Theme.of(context).textTheme.titleMedium),
                          content: Column(
                            children: <Widget>[
                              LargeTextField(
                                  controller: nameController,
                                  hintText: 'Full Name'),
                              LargeTextField(
                                  controller: usernameController,
                                  hintText: 'Username'),
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
                              DefaultTextStyle(
                                style: Theme.of(context).textTheme.labelLarge!,
                                child: CheckboxListTile(
                                  title: const Text('Admin'),
                                  value: isAdmin,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      isAdmin = value!;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          actions: <Widget>[
                            FilledButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            FilledButton(
                              child: const Text('Add'),
                              onPressed: () {
                                if (passwordController.text !=
                                    confirmPasswordController.text) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'The passwords do not match. Please try again.'),
                                    ),
                                  );
                                } else {
                                  serverCreateUser(
                                    fullName: nameController.text,
                                    username: usernameController.text,
                                    password: passwordController.text,
                                    isAdmin: isAdmin,
                                  ).then((response) {
                                    if (response.success) {
                                      setState(
                                          () => users.add(response.value!));
                                      displaySnackbar(context,
                                          'User "${response.value!.fullName}" added');
                                    } else {
                                      displaySnackbar(
                                        context,
                                        response.message ?? 'An error occurred',
                                      );
                                    }
                                    Navigator.of(context).pop();
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: const Text('Add User'),
          ),
        ),
      ],
    );
  }
}
