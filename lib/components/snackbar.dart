import 'package:flutter/material.dart';

void displaySnackbar(BuildContext context, String message) {
  hideSnackbar(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Center(child: Text(message)),
    ),
  );
}

void hideSnackbar(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}
