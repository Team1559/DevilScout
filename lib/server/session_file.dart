import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

import '/server/auth.dart';
import '/server/server.dart';
import '/server/session.dart';

const String _sessionFile = 'session.json';

/// Attempt to load a cached user session from device storage (for auto
/// login). If present, the server will confirm its validity. Returns whether
/// a session was successfully initialized. This should not be called by user
/// code.
Future<bool> loadCachedSession() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/$_sessionFile');
  if (!file.existsSync()) {
    return false;
  }

  String sessionStr = file.readAsStringSync();
  Session.current = Session.fromJson(jsonDecode(sessionStr));

  ServerResponse<void> response = await serverGetSession();
  return response.success;
}

/// Set the current session. This should not be called by user code.
void saveSession() {
  getApplicationDocumentsDirectory().then((directory) {
    File file = File('${directory.path}/$_sessionFile');
    if (Session.current == null) {
      file.deleteSync();
    } else {
      file.createSync();
      file.writeAsString(jsonEncode(Session.current));
    }
  });
}
