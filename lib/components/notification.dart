import 'package:flutter/material.dart';
import 'package:in_app_notification/in_app_notification.dart';

import '/theme.dart';

const Duration _forever = Duration(days: 999999999999999999);

void showNotification({
  required BuildContext context,
  required Widget child,
  bool persist = false,
  void Function()? onTap,
}) =>
    InAppNotification.show(
      context: context,
      child: child,
      duration: persist ? _forever : const Duration(milliseconds: 5000),
      dismissCurve: Curves.easeInBack,
      onTap: onTap,
    );

void dismissNotification({
  required BuildContext context,
}) =>
    InAppNotification.dismiss(
      context: context,
    );

enum NotificationLevel {
  error,
  warning,
  info;

  Color _backgroundColor() {
    if (ThemeModeHelper.isDarkMode) {
      return switch (this) {
        error => Colors.red.shade600,
        warning => Colors.orange.shade800,
        info => Colors.blue.shade700,
      };
    } else {
      return switch (this) {
        error => Colors.red.shade600,
        warning => Colors.orange.shade800,
        info => Colors.blue.shade700,
      };
    }
  }
}

class Notification extends StatelessWidget {
  final NotificationLevel level;
  final String title;
  final String? body;

  const Notification({
    super.key,
    required this.level,
    required this.title,
    this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: level._backgroundColor(),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (body != null)
              Text(
                body!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
          ],
        ),
      ),
    );
  }
}
