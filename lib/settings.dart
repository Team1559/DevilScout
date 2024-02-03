import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:synchronized/synchronized.dart';

part 'settings.g.dart';

AppSettings? _globalSettings;
Lock _globalSettingsLock = Lock();

Future<AppSettings> getSettings() =>
    _globalSettings == null ? _loadSettings() : Future.value(_globalSettings!);

Future<AppSettings> _loadSettings() async {
  if (_globalSettings != null) return _globalSettings!;

  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/settings.json');

  if (file.existsSync()) {
    String json = file.readAsStringSync();
    _globalSettings = AppSettings.fromJson(jsonDecode(json));
  } else {
    _globalSettings = AppSettings();
    await _globalSettings!._writeToFile();
  }

  return _globalSettings!;
}

@JsonSerializable()
class AppSettings with ChangeNotifier, WidgetsBindingObserver {
  ThemeMode _theme;
  ThemeMode get theme => _theme;
  set theme(ThemeMode theme) {
    _theme = theme;
    notifyListeners();
    _writeToFile();
  }

  AppSettings({ThemeMode theme = ThemeMode.system}) : _theme = theme {
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    notifyListeners();
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) =>
      _$AppSettingsFromJson(json);

  Map<String, dynamic> toJson() => _$AppSettingsToJson(this);

  Future<void> _writeToFile() => _globalSettingsLock.synchronized(() {
        String json = jsonEncode(this);
        getApplicationDocumentsDirectory().then((directory) {
          File file = File('${directory.path}/settings.json');
          file.writeAsString(json);
        });
      });
}
