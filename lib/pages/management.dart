import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';
import '/components/snackbar.dart';
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
                    return const CircularProgressIndicator();
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
              // Add your button function here
            },
            child: const Text('Add User'),
          ),
        ),
      ],
    );
  }
}
