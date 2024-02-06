import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  static final Uri website = Uri.parse('https://scouting.victorrobotics.org');

  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Text(
              '''
Devil Scout is a scouting app for FRC, designed for teams who lack the resources to effectively collect and analyze data on their own.

In late 2023, developers Nolan Martin and Xander Bhalla proposed creating an online scouting experience for Team 1559. It has since evolved from a single-team app to a public project, and we hope it serves as a permanent solution for both rookies and veterans alike.

We're taking a different approach to scouting in FRC. Rather than isolating each team's data, we pool everything from each event in order to produce more accurate analysis. All teams, big or small, have access to all of the data to inform their decisions, leveling the playing field.

For more information, visit our website:''',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            GestureDetector(
              child: Text(
                'scouting.victorrobotics.org',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
              onTap: () => launchUrl(website),
            ),
          ],
        ),
      ),
    );
  }
}
