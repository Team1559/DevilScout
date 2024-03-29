import 'package:flutter/material.dart' hide Notification;

import '/components/logout.dart';
import '/components/notification.dart';
import '/components/text_field.dart';
import '/server/auth.dart';
import '/server/server.dart';
import '/server/session_file.dart';
import '/server/users.dart';

class UserEditDialog extends StatefulWidget {
  final User? user;
  final bool showAdmin;

  const UserEditDialog({
    super.key,
    this.user,
    required this.showAdmin,
  });

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  late bool isAdmin;

  @override
  void initState() {
    super.initState();

    isAdmin = widget.user?.isAdmin ?? false;

    if (widget.user != null) {
      nameController.text = widget.user!.fullName;
      usernameController.text = widget.user!.username;
    }

    nameController.addListener(_listener);
    usernameController.addListener(_listener);
    passwordController.addListener(_listener);
    confirmPasswordController.addListener(_listener);
  }

  void _listener() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, widget.user),
                  ),
                  const Spacer(),
                  Text(
                    widget.user == null ? 'Add User' : 'Edit User',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  IconButton.filled(
                    onPressed:
                        _areFieldsValid() ? () => _tryEditUser(context) : null,
                    icon: const Icon(Icons.check),
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: TextFieldDecoration(
                      hintText: 'Full Name',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: usernameController,
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: TextFieldDecoration(
                      hintText: 'Username',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: TextFieldDecoration(
                      hintText: 'Password',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    style: Theme.of(context).textTheme.labelLarge,
                    decoration: TextFieldDecoration(
                      hintText: 'Confirm Password',
                      colorScheme: Theme.of(context).colorScheme,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (widget.showAdmin)
                    ListTile(
                      title: Text(
                        'Administrator',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      trailing: Checkbox(
                        value: isAdmin,
                        onChanged: (value) {
                          if (value! == (widget.user != User.current)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Are you sure?'),
                                content: widget.user != User.current
                                    ? const Text(
                                        'This user will have administrator access, which you cannot revoke.',
                                      )
                                    : const Text(
                                        "If you revoke your administrator privileges, you won't be able to manage your team's event or users.",
                                      ),
                                actions: [
                                  TextButton(
                                    onPressed: Navigator.of(context).pop,
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      setState(() => isAdmin = !isAdmin);
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Continue'),
                                  ),
                                ],
                              ),
                            );
                          } else {
                            setState(() => isAdmin = !isAdmin);
                          }
                        },
                      ),
                    ),
                  if (widget.user != null)
                    TextButton(
                      child: const Text('Delete User'),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Are you sure?'),
                            content: widget.user == User.current
                                ? const Text(
                                    'You will be logged out immediately, and your account will be permanently erased. We will retain any scouting data you submitted, but it will be disassociated with your identity.\n\nThis action is irreversible.',
                                  )
                                : const Text(
                                    'This account will be permanently erased. Any scouting data they submitted will be anonymized, but remain associated with your team.\n\nThis action is irreversible.',
                                  ),
                            actions: [
                              TextButton(
                                onPressed: Navigator.of(context).pop,
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                child: const Text('Delete'),
                                onPressed: () => deleteUser(context),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteUser(BuildContext context) async {
    ServerResponse<void> response =
        await serverDeleteUser(id: widget.user!.id).then(detectLogout(context));
    if (!context.mounted) return;

    if (!response.success) {
      showNotification(
        context: context,
        child: Notification(
          level: NotificationLevel.error,
          title: response.message ?? 'An error occurred',
        ),
      );
      return;
    }

    if (User.allUsers.contains(widget.user)) {
      User.allUsers.remove(widget.user);
    }

    if (widget.user == User.current) {
      serverLogout().whenComplete(saveSession);
      pushLoginPage(context);
    } else {
      Navigator.pop(context);
      Navigator.pop(context);
    }
  }

  bool _areFieldsValid() {
    String fullName = nameController.text;
    if (fullName.isEmpty) return false;

    String username = usernameController.text;
    if (username.isEmpty) return false;

    String password = passwordController.text;
    if (password != confirmPasswordController.text) return false;
    if (password.isNotEmpty && password.length < 8) return false;
    if (password.isEmpty && widget.user == null) return false;

    if (widget.user != null &&
        fullName == widget.user!.fullName &&
        username == widget.user!.username &&
        password.isEmpty &&
        isAdmin == widget.user?.isAdmin) {
      return false;
    }

    return true;
  }

  Future<void> _tryEditUser(BuildContext context) async {
    String password = passwordController.text;
    String username = usernameController.text;
    String fullName = nameController.text;

    if (password.isNotEmpty &&
        (password.toLowerCase().contains(username.toLowerCase()) ||
            password.toLowerCase().contains(fullName.toLowerCase()))) {
      showNotification(
        context: context,
        child: const Notification(
          level: NotificationLevel.warning,
          title: 'Password should not contain name',
        ),
      );
      return;
    }

    ServerResponse<User> response;
    if (widget.user == null) {
      response = await serverCreateUser(
        fullName: nameController.text,
        username: usernameController.text,
        password: passwordController.text,
        isAdmin: isAdmin,
      ).then(detectLogout(context));
    } else {
      response = await serverEditUser(
        id: widget.user!.id,
        username: username == widget.user!.username ? null : username,
        fullName: fullName == widget.user!.fullName ? null : fullName,
        password: password.isEmpty ? null : password,
        isAdmin: widget.user!.isAdmin == isAdmin ? null : isAdmin,
      ).then(detectLogout(context));
    }
    if (!context.mounted) return;

    if (!response.success) {
      showNotification(
        context: context,
        child: Notification(
          level: NotificationLevel.error,
          title: response.message ?? 'An error occurred',
        ),
      );
      return;
    }

    Navigator.pop(context, response.value!);
  }
}
