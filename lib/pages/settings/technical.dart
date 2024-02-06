import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/server/server.dart';

class TechnicalPage extends StatefulWidget {
  const TechnicalPage({super.key});

  @override
  State<TechnicalPage> createState() => _TechnicalPageState();
}

class _TechnicalPageState extends State<TechnicalPage> {
  PackageInfo? _packageInfo;
  BaseDeviceInfo? _deviceInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Future.wait([
      DeviceInfoPlugin().deviceInfo.then((value) => _deviceInfo = value),
      PackageInfo.fromPlatform().then((value) => _packageInfo = value),
    ]).whenComplete(() => setState(() => _loading = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Technical'),
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: Builder(builder: (context) {
          if (_loading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            children: [
              heading('App Info', context),
              body(appInfo(), context),
              const SizedBox(height: 8),
              heading('Device Info', context),
              body(deviceInfo(), context),
              const SizedBox(height: 8),
              heading('Server Info', context),
              body(serverInfoStr(), context),
            ],
          );
        }),
      ),
    );
  }

  Text heading(String heading, BuildContext context) {
    return Text(
      heading,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Text body(String text, BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge,
    );
  }

  String appInfo() {
    return _packageInfo == null
        ? 'Unknown version'
        : '${_packageInfo!.appName}\nVersion ${_packageInfo!.buildNumber}';
  }

  String deviceInfo() {
    return switch (_deviceInfo) {
      IosDeviceInfo ios =>
        '${ios.utsname.machine}\n${ios.systemName} ${ios.systemVersion}',
      AndroidDeviceInfo android => '${android.model}\n${android.version}',
      _ => 'Unknown runtime',
    };
  }

  String serverInfoStr() {
    return '$serverApiUri';
  }
}
