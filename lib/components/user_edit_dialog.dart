import 'package:flutter/material.dart';

import '/server/server.dart';
import '/server/users.dart';
import 'large_text_field.dart';
import 'snackbar.dart';

class UserEditDialog extends StatefulWidget {
  final User? user;

  const UserEditDialog({super.key, this.user});

  @override
  State<UserEditDialog> createState() => _UserEditDialogState();
}

class _UserEditDialogState extends State<UserEditDialog> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit User'),
        centerTitle: true,
        actions: [
          IconButton.filled(
            onPressed: _areFieldsValid() ? () => _tryEditUser(context) : null,
            icon: const Icon(Icons.check),
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

    return true;
  }

  Future<void> _tryEditUser(BuildContext context) async {
    String password = passwordController.text;
    String username = usernameController.text;
    String fullName = nameController.text;

    if (password.isNotEmpty &&
        (password.toLowerCase().contains(username.toLowerCase()) ||
            password.toLowerCase().contains(fullName.toLowerCase()))) {
      displaySnackbar(context, 'Password should not contain name');
      return;
    }

    ServerResponse<User> response;
    if (widget.user == null) {
      response = await serverCreateUser(
        fullName: nameController.text,
        username: usernameController.text,
        password: passwordController.text,
      );
    } else {
      response = await serverEditUser(
        id: widget.user!.id,
        username: username == widget.user!.username ? null : username,
        fullName: fullName == widget.user!.fullName ? null : fullName,
        password: password.isEmpty ? null : password,
      );
    }
    if (!context.mounted) return;

    if (!response.success) {
      displaySnackbar(
        context,
        response.message ?? 'An error occurred',
      );
      return;
    }

    Navigator.pop(context, response.value!);
  }
}
