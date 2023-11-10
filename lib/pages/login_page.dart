import 'package:devil_scout/authentication.dart';
import 'package:flutter/material.dart';
import '../components/large_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final teamNumberController = TextEditingController();
  final usernameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
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

              TextButton(
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
