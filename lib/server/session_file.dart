import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import 'server.dart';
import 'session.dart';
import 'teams.dart';
import 'users.dart';

/// Attempt to load a cached user session from device storage (for auto
/// login). If present, the server will confirm its validity. Returns whether
/// a session was successfully initialized. This should not be called by user
/// code.
Future<bool> loadSessionFromFile() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/session.txt');
  if (!file.existsSync()) {
    return false;
  }

  String sessionKey = file.readAsStringSync();
  ServerResponse<Session> response =
      await serverGetSession(sessionKey: sessionKey);
  if (!response.success) {
    return false;
  }

  Session.current = response.value!;
  await Future.wait([
    serverGetCurrentUser(),
    serverGetCurrentTeam(),
  ]);
  return true;
}

/// Set the current session. This should not be called by user code.
void setSession(Session? session) {
  Session.current = session;

  getApplicationDocumentsDirectory().then((directory) {
    File file = File('${directory.path}/session.txt');
    if (session == null) {
      file.deleteSync();
    } else {
      file.createSync();
      file.writeAsString(session.key);
    }
  });
}
