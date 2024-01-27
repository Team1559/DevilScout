import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/large_text_field.dart';
import '/components/loading_overlay.dart';
import '/components/snackbar.dart';
import '/server/auth.dart';
import '/server/server.dart';
import '/server/session.dart';
import '/server/session_file.dart';
import '/server/teams.dart';
import '/server/users.dart';
import 'match_scout_select.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Scaffold(
        body: LoadingOverlay(
          child: SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome,\nlet's get you logged in.",
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 20),
                const _LoginFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginFields extends StatefulWidget {
  const _LoginFields();

  @override
  State<_LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<_LoginFields> {
  final _teamNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _showingPassword = false;

  @override
  void initState() {
    super.initState();

    _teamNumber.addListener(_listener);
    _username.addListener(_listener);
    _password.addListener(_listener);
  }

  void _listener() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 175),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: Offset(child is PasswordInput ? 2 : -2, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: _showingPassword
            ? PasswordInput(
                username: _username.text,
                teamNum: int.parse(_teamNumber.text),
                passwordController: _password,
                previousAction: () => setState(() => _showingPassword = false),
                loginAction: (auth) {
                  Session.current = auth.session;
                  Team.current = auth.team;
                  User.current = auth.user;
                  saveSession();

                  hideSnackbar(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MatchSelectPage()),
                  );
                },
              )
            : UsernameInput(
                usernameController: _username,
                teamNumController: _teamNumber,
                continueAction: () {
                  setState(() {
                    _password.clear();
                    _showingPassword = true;
                  });
                },
              ),
      ),
    );
  }
}

class UsernameInput extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController teamNumController;
  final void Function()? continueAction;

  const UsernameInput({
    super.key,
    required this.usernameController,
    required this.teamNumController,
    required this.continueAction,
  });

  @override
  State<UsernameInput> createState() => _UsernameInputState();
}

class _UsernameInputState extends State<UsernameInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeTextField(
          controller: widget.usernameController,
          hintText: 'Username',
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
          textInputAction: TextInputAction.next,
        ),
        LargeTextField(
          controller: widget.teamNumController,
          hintText: 'Team Number',
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
        ),
        FilledButton(
          onPressed: widget.usernameController.text.isNotEmpty &&
                  widget.teamNumController.text.isNotEmpty
              ? () async {
                  ServerResponse<void> response = await serverLogin(
                    team: int.parse(widget.teamNumController.text),
                    username: widget.usernameController.text,
                  );
                  if (!context.mounted) return;

                  if (!response.success) {
                    displaySnackbar(context, response.toString());
                    return;
                  }

                  hideSnackbar(context);
                  setState(() {
                    widget.continueAction?.call();
                  });
                }
              : null,
          child: const Text('Next'),
        ),
      ],
    );
  }
}

class PasswordInput extends StatefulWidget {
  final String username;
  final int teamNum;
  final TextEditingController passwordController;
  final void Function() previousAction;
  final void Function(AuthResponse auth) loginAction;

  const PasswordInput({
    super.key,
    required this.username,
    required this.teamNum,
    required this.passwordController,
    required this.previousAction,
    required this.loginAction,
  });

  @override
  State<PasswordInput> createState() => _PasswordInputState();
}

class _PasswordInputState extends State<PasswordInput> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LargeTextField(
          controller: widget.passwordController,
          hintText: 'Password',
          obscureText: true,
          autofocus: true,
        ),
        FilledButton(
          onPressed: widget.passwordController.text.isEmpty
              ? null
              : () {
                  LoadingOverlay.of(context).show();

                  serverAuthenticate(
                    password: widget.passwordController.text,
                  ).then((response) {
                    LoadingOverlay.of(context).hide();

                    if (!response.success) {
                      displaySnackbar(context, response.toString());
                      return;
                    }

                    AuthResponse auth = response.value!;
                    widget.loginAction.call(auth);
                  });
                },
          child: const Text('Log In'),
        ),
        TextButton(
          onPressed: widget.previousAction,
          child: const Text('Back'),
        ),
      ],
    );
  }
}
