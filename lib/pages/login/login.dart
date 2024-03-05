import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/loading_overlay.dart';
import '/components/snackbar.dart';
import '/components/text_field.dart';
import '/pages/scout/select_match.dart';
import '/server/auth.dart';
import '/server/session.dart';
import '/server/session_file.dart';
import '/server/teams.dart';
import '/server/users.dart';

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
                const LoginFields(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginFields extends StatefulWidget {
  const LoginFields({super.key});

  @override
  State<LoginFields> createState() => _LoginFieldsState();
}

class _LoginFieldsState extends State<LoginFields> {
  static const Duration animationDuration = Duration(milliseconds: 175);

  final _teamNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _showingUsername = true;

  FocusNode usernameFocus = FocusNode();
  FocusNode teamNumberFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

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
        duration: animationDuration,
        transitionBuilder: (child, animation) => SlideTransition(
          position: Tween(
            begin: Offset(child is PasswordInput ? 2 : -2, 0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
        child: visibleFields(context),
      ),
    );
  }

  Widget visibleFields(BuildContext context) {
    if (_showingUsername) {
      return UsernameInput(
        usernameController: _username,
        teamNumController: _teamNumber,
        usernameFocusNode: usernameFocus,
        teamNumberFocusNode: teamNumberFocus,
        continueAction: () => setState(() {
          _showingUsername = false;
          passwordFocus.requestFocus();
        }),
      );
    } else {
      return PasswordInput(
        username: _username.text,
        teamNum: int.parse(_teamNumber.text),
        passwordController: _password,
        focusNode: usernameFocus,
        previousAction: () => setState(() {
          _showingUsername = true;
          teamNumberFocus.requestFocus();
          Future.delayed(animationDuration, _password.clear);
        }),
        loginAction: (auth) {
          Session.current = auth.session;
          Team.current = auth.team;
          User.current = auth.user;
          saveSession();

          hideError(context);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MatchSelectPage()),
          );
        },
      );
    }
  }
}

class UsernameInput extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController teamNumController;
  final FocusNode usernameFocusNode;
  final FocusNode teamNumberFocusNode;
  final void Function() continueAction;

  const UsernameInput({
    super.key,
    required this.usernameController,
    required this.teamNumController,
    required this.usernameFocusNode,
    required this.teamNumberFocusNode,
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
        TextField(
          controller: widget.usernameController,
          style: Theme.of(context).textTheme.labelLarge,
          decoration: TextFieldDecoration(
            hintText: 'Username',
            colorScheme: Theme.of(context).colorScheme,
          ),
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
          textInputAction: TextInputAction.next,
          autofocus: true,
          focusNode: widget.usernameFocusNode,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.teamNumController,
          style: Theme.of(context).textTheme.labelLarge,
          decoration: TextFieldDecoration(
            hintText: 'Team Number',
            colorScheme: Theme.of(context).colorScheme,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            const NumberTextInputFormatter(min: 0, max: 9999),
          ],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          onSubmitted: tryLogin(),
          focusNode: widget.teamNumberFocusNode,
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: tryLogin(),
          child: const Text('Next'),
        ),
      ],
    );
  }

  void Function([String?])? tryLogin() {
    if (widget.usernameController.text.isEmpty ||
        widget.teamNumController.text.isEmpty) return null;

    return ([String? _]) {
      serverLogin(
        team: int.parse(widget.teamNumController.text),
        username: widget.usernameController.text,
      ).then((response) {
        if (!context.mounted) return;

        if (!response.success) {
          snackbarError(context, response.toString());
          return;
        }

        hideError(context);
        widget.continueAction();
      });
    };
  }
}

class PasswordInput extends StatefulWidget {
  final String username;
  final int teamNum;
  final TextEditingController passwordController;
  final FocusNode focusNode;
  final void Function() previousAction;
  final void Function(AuthResponse auth) loginAction;

  const PasswordInput({
    super.key,
    required this.username,
    required this.teamNum,
    required this.passwordController,
    required this.focusNode,
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
        TextField(
          style: Theme.of(context).textTheme.labelLarge,
          controller: widget.passwordController,
          decoration: TextFieldDecoration(
            hintText: 'Password',
            colorScheme: Theme.of(context).colorScheme,
          ),
          obscureText: true,
          autofocus: true,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: tryAuth(context),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: tryAuth(context),
          child: const Text('Log In'),
        ),
        TextButton(
          onPressed: widget.previousAction,
          child: const Text('Back'),
        ),
      ],
    );
  }

  void Function([String?])? tryAuth(BuildContext context) {
    if (widget.passwordController.text.isEmpty) return null;

    return ([String? _]) {
      LoadingOverlay.of(context).show();

      serverAuthenticate(
        password: widget.passwordController.text,
      ).then((response) {
        LoadingOverlay.of(context).hide();

        if (!response.success) {
          snackbarError(context, response.toString());
          return;
        }

        AuthResponse auth = response.value!;
        widget.loginAction.call(auth);
      });
    };
  }
}
