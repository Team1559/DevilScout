import 'package:devil_scout/main.dart';
import 'package:devil_scout/server/auth.dart';
import 'package:devil_scout/theme/theme_manager.dart';
import 'package:flutter/material.dart';
import 'package:devil_scout/components/large_text_field.dart';

class LoginPage extends StatefulWidget {
  final ThemeManager themeManager;

  const LoginPage({Key? key, required this.themeManager}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final teamNumberController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("DevilScout"), actions: [
          Switch(
            value: themeManager.themeMode == ThemeMode.dark,
            onChanged: (newValue) {
              widget.themeManager.toggleTheme(newValue);
            },
          )
        ]),
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
            child: Center(
          child: Column(
            children: [
              const SizedBox(height: 65),
              const Text("Log In",
                  style: TextStyle(
                    fontSize: 50,
                  )),
              const SizedBox(height: 75),

              // Team Number Input Field
              LargeTextField(
                controller: teamNumberController,
                hintText: "Team Number",
                obscureText: false,
              ),
              const SizedBox(height: 20),

              // Username Input Field
              LargeTextField(
                controller: usernameController,
                hintText: "Username",
                obscureText: false,
              ),

              const SizedBox(
                height: 25,
              ),

              FilledButton(
                onPressed: () async {
                  final LoginStatus? response = await login(
                      int.parse(teamNumberController.text),
                      usernameController.text);
                  print(response);
                  if (response != null) {
                    final Session? session =
                        await authenticate(response, 'password');
                    print(session);
                  }
                },
                child: const Text("Log In"),
              ),
            ],
          ),
        )));
  }
}
