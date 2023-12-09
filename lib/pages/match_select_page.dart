import 'package:flutter/material.dart';

class MatchSelectPage extends StatefulWidget {
  const MatchSelectPage({Key? key}) : super(key: key);

  @override
  State<MatchSelectPage> createState() => _MatchSelectPageState();
}

class _MatchSelectPageState extends State<MatchSelectPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scouting'),
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu),
        ),
      ),
      body: ListView.builder(
        shrinkWrap: true,
        itemCount: 5,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text('Qualifier ${index + 1}'),
                  const SizedBox(height: 10.0),
                  const Text('1559 3010 6781'),
                  const Text('4052 5678 3071'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
