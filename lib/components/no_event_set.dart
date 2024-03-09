import 'package:flutter/material.dart';

import '/pages/management/manage.dart';
import '/server/users.dart';

class NoEventSetWidget extends StatelessWidget {
  const NoEventSetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No event set',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            if (User.current.isAdmin)
              FilledButton(
                child: const Text('Go to team management'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ManagementPage(),
                    ),
                  );
                },
              )
            else
              Text(
                'Ask your team admins to configure',
                style: Theme.of(context).textTheme.bodyLarge,
              )
          ],
        ),
      ),
    );
  }
}
