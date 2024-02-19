import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:git_info_plus/git_info_plus.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '/server/server.dart';

class TechnicalPage extends StatefulWidget {
  const TechnicalPage({super.key});

  @override
  State<TechnicalPage> createState() => _TechnicalPageState();
}

class _TechnicalPageState extends State<TechnicalPage> {
  static final DateFormat _dateFormat = DateFormat('MM/dd/yyyy');

  PackageInfo? _packageInfo;
  BaseDeviceInfo? _deviceInfo;
  GitCommitInfo? _gitInfo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    Future.wait([
      DeviceInfoPlugin().deviceInfo.then((value) => _deviceInfo = value),
      PackageInfo.fromPlatform().then((value) => _packageInfo = value),
      GitCommitInfo.current().then((value) => _gitInfo = value),
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
              body(gitInfo(), context),
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
        ? 'App version unavailable'
        : '${_packageInfo!.appName}\nVersion ${_packageInfo!.buildNumber}';
  }

  String gitInfo() {
    return _gitInfo == null
        ? 'Git metadata unavailable'
        : '${_gitInfo!.branch} (${_gitInfo!.commitHash}) - ${_gitInfo!.commitDate == null ? '' : _dateFormat.format(_gitInfo!.commitDate!)}';
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

class GitCommitInfo {
  final String? branch;
  final String? commitHash;
  final DateTime? commitDate;

  GitCommitInfo({
    required this.branch,
    required this.commitHash,
    required this.commitDate,
  });

  static Future<GitCommitInfo> current() => Future.wait([
        GitInfo.branchName,
        GitInfo.lastCommitHashShort,
        GitInfo.lastCommitDate,
      ]).then((value) => GitCommitInfo(
            branch: value[0] as String?,
            commitHash: value[1] as String?,
            commitDate: value[2] as DateTime?,
          ));
}
