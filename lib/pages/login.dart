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

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    "Welcome,\nlet's get you logged in.",
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.left,
                  ),
                ),
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
  static const Key _usernameKey = Key('username');
  static const Key _passwordKey = Key('password');

  final _teamNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _showingPassword = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 175),
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: Offset(child.key == _passwordKey ? 2 : -2, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: _showingPassword ? _passwordInput() : _userAndTeamInput(),
      ),
    );
  }

  Widget _userAndTeamInput() {
    return Column(
      key: _usernameKey,
      children: [
        LargeTextField(
          controller: _username,
          hintText: 'Username',
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
          textInputAction: TextInputAction.next,
        ),
        LargeTextField(
          controller: _teamNumber,
          hintText: 'Team Number',
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
        ),
        FilledButton(
          style: const ButtonStyle(
            minimumSize: MaterialStatePropertyAll(
              Size(double.infinity, 48.0),
            ),
          ),
          child: const Text('Next'),
          onPressed: () async {
            if (_username.text.isEmpty) {
              displaySnackbar(context, 'Enter your username');
              return;
            } else if (_teamNumber.text.isEmpty) {
              displaySnackbar(context, 'Enter your team number');
              return;
            }

            ServerResponse<void> response = await serverLogin(
              team: int.parse(_teamNumber.text),
              username: _username.text,
            );
            if (!context.mounted) return;

            if (!response.success) {
              displaySnackbar(context, response.toString());
              return;
            }

            hideSnackbar(context);
            setState(() {
              _password.clear();
              _showingPassword = true;
            });
          },
        ),
      ],
    );
  }

  Widget _passwordInput() {
    return Column(
      key: _passwordKey,
      children: [
        LargeTextField(
          controller: _password,
          hintText: 'Password',
          obscureText: true,
        ),
        FilledButton(
          style: const ButtonStyle(
            minimumSize: MaterialStatePropertyAll(
              Size(double.infinity, 48.0),
            ),
          ),
          onPressed: () {
            if (_password.text.isEmpty) {
              displaySnackbar(context, 'Enter your password');
              return;
            }

            LoadingOverlay.of(context).show();

            serverAuthenticate(
              password: _password.text,
            ).then((response) {
              LoadingOverlay.of(context).hide();

              if (!response.success) {
                displaySnackbar(context, response.toString());
                return;
              }

              AuthResponse auth = response.value!;
              Session.current = auth.session;
              Team.currentTeam = auth.team;
              User.currentUser = auth.user;
              saveSession();

              hideSnackbar(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const MatchSelectPage()),
              );
            });
          },
          child: const Text('Log In'),
        ),
        TextButton(
          onPressed: () => setState(() => _showingPassword = false),
          child: const Text('Back'),
        ),
      ],
    );
  }
}
