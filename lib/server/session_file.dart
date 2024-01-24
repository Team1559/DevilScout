import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'server.dart';
import 'session.dart';

/// Attempt to load a cached user session from device storage (for auto
/// login). If present, the server will confirm its validity. Returns whether
/// a session was successfully initialized. This should not be called by user
/// code.
Future<Session?> loadSessionFromFile() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/session.txt');
  if (!file.existsSync()) {
    return null;
  }

  String sessionKey = file.readAsStringSync();
  Session.current = Session(key: sessionKey, user: "", team: 0);

  ServerResponse<Session> response = await serverGetSession();
  if (!response.success) {
    return null;
  }

  return response.value;
}

/// Set the current session. This should not be called by user code.
void saveSession() {
  getApplicationDocumentsDirectory().then((directory) {
    File file = File('${directory.path}/session.txt');
    if (Session.current == null) {
      file.deleteSync();
    } else {
      file.createSync();
      file.writeAsString(Session.current!.key);
    }
  });
}
