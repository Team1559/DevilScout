import 'package:flutter/material.dart';

void snackbarError(BuildContext context, String message) {
  hideError(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Theme.of(context).colorScheme.error,
      content: Center(
        child: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .labelLarge!
              .copyWith(color: Theme.of(context).colorScheme.onError),
        ),
      ),
    ),
  );
}

void hideError(BuildContext context) {
  ScaffoldMessenger.of(context).clearSnackBars();
}
