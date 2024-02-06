import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: ListView(
          children: [
            
          ],
        ),
      ),
    );
  }
}
