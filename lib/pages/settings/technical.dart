import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class TechnicalPage extends StatefulWidget {
  const TechnicalPage({super.key});

  @override
  State<TechnicalPage> createState() => _TechnicalPageState();
}

class _TechnicalPageState extends State<TechnicalPage> {
  PackageInfo? packageInfo;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    PackageInfo.fromPlatform()
        .then((info) => setState(() => packageInfo = info));
  }

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
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  packageInfo == null
                      ? 'Loading...'
                      : '${packageInfo!.appName} Version ${packageInfo!.version}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
