import 'package:flutter/material.dart';

import '/pages/login/login.dart';
import '/server/server.dart';

void pushLoginPage(BuildContext context) {
  serverClearCachedData();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}

void logoutDialog(BuildContext context) {
  _delayedLogout = false;
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Logged out'),
      content: const Text(
        'The server indicated your session has expired. Please log in again to continue.',
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Okay'),
        ),
      ],
    ),
  ).whenComplete(() => pushLoginPage(context));
}

bool _delayedLogout = false;

void detectDelayedLogout(BuildContext context) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (_delayedLogout) {
      _delayedLogout = false;
      logoutDialog(context);
    }
  });
}

ServerResponse<T> Function(ServerResponse<T>) detectLogout<T>([
  BuildContext? context,
  void Function()? beforeDialog,
]) =>
    context == null
        ? (response) {
            if (response.statusCode == 401) {
              _delayedLogout = true;
            }
            return response;
          }
        : (response) {
            if (response.statusCode == 401 || _delayedLogout) {
              beforeDialog?.call();
              logoutDialog(context);
            }
            return response;
          };
