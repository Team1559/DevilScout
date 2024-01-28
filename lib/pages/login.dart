import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/components/large_text_field.dart';
import '/components/loading_overlay.dart';
import '/components/snackbar.dart';
import '/server/auth.dart';
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
  static const Duration animationDuration = Duration(milliseconds: 175);

  final _teamNumber = TextEditingController();
  final _username = TextEditingController();
  final _password = TextEditingController();

  bool _showingPassword = false;

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
    if (!_showingPassword) {
      return UsernameInput(
        usernameController: _username,
        teamNumController: _teamNumber,
        usernameFocusNode: usernameFocus,
        teamNumberFocusNode: teamNumberFocus,
        continueAction: () => setState(() {
          _showingPassword = true;
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
          _showingPassword = false;
          teamNumberFocus.requestFocus();
          Future.delayed(animationDuration, _password.clear);
        }),
        loginAction: (auth) {
          Session.current = auth.session;
          Team.current = auth.team;
          User.current = auth.user;
          saveSession();

          hideSnackbar(context);
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
        LargeTextField(
          controller: widget.usernameController,
          hintText: 'Username',
          inputFormatters: [
            LengthLimitingTextInputFormatter(32),
          ],
          textInputAction: TextInputAction.next,
          autofocus: true,
          focusNode: widget.usernameFocusNode,
        ),
        LargeTextField(
          controller: widget.teamNumController,
          hintText: 'Team Number',
          inputFormatters: [
            LengthLimitingTextInputFormatter(4),
            FilteringTextInputFormatter.digitsOnly,
          ],
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.continueAction,
          onSubmitted: tryLogin(),
          focusNode: widget.teamNumberFocusNode,
        ),
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
          displaySnackbar(context, response.toString());
          return;
        }

        hideSnackbar(context);
        widget.continueAction.call();
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
        LargeTextField(
          controller: widget.passwordController,
          hintText: 'Password',
          obscureText: true,
          autofocus: true,
          focusNode: widget.focusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: tryAuth(context),
        ),
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
          displaySnackbar(context, response.toString());
          return;
        }

        AuthResponse auth = response.value!;
        widget.loginAction.call(auth);
      });
    };
  }
}
