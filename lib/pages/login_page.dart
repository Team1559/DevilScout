import 'package:devil_scout/components/large_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/server/auth.dart';
import '/server/server.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _teamNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  final Key _usernameKey = const Key('username');
  final Key _passwordKey = const Key('password');

  bool _showingPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 32),
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 65),
              Text(
                'Welcome',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 75),
              const Icon(
                Icons.image,
                size: 200,
              ),
              const SizedBox(height: 75),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  final inAnimation = Tween(
                    begin: const Offset(2, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  final outAnimation = Tween(
                    begin: const Offset(-2, 0),
                    end: Offset.zero,
                  ).animate(animation);
                  return SlideTransition(
                    position:
                        child.key == _passwordKey ? inAnimation : outAnimation,
                    child: child,
                  );
                },
                child:
                    _showingPassword ? _passwordInput() : _userAndTeamInput(),
              ),
            ],
          ),
        ),
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
          obscureText: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
        LargeTextField(
          controller: _teamNumber,
          hintText: 'Team Number',
          obscureText: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.digitsOnly,
          ],
        ),
        FilledButton(
          onPressed: _onNextPressed,
          child: const Text('Next'),
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
          obscureText: false,
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
        ),
        FilledButton(
          onPressed: _onLoginPressed,
          child: const Text('Log In'),
        ),
        TextButton(
          onPressed: () async {
            setState(() {
              _showingPassword = false;
            });
          },
          child: const Text('Back'),
        ),
      ],
    );
  }

  Future<void> _onNextPressed() async {
    ServerResponse<void> response = await serverLogin(
      team: int.parse(_teamNumber.text),
      username: _username.text,
    );

    if (response.success) {
      setState(() {
        _showingPassword = true;
      });
    } else {
      // display error message
    }
  }

  Future<void> _onLoginPressed() async {
    ServerResponse<void> response = await serverAuthenticate(
      password: _password.text,
    );

    if (response.success) {
      await Navigator.pushNamed(context, '/scouting/match/select');
    } else {
      // display error message
    }
  }
}
