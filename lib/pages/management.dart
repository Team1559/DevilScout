import 'package:flutter/material.dart';

import '/components/navigation_drawer.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => ManagementPageState();
}

class ManagementPageState extends State<ManagementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Management'),
      ),
      body: const Text('This is the Management Page'),
      drawer: const NavDrawer(),
    );
  }
}
