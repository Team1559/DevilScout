import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:path_provider/path_provider.dart';

import 'server.dart';
import 'teams.dart';
import 'users.dart';

part 'session.g.dart';

/// An authorized user session, containing user info as well as permissions
@JsonSerializable(createToJson: false)
class Session {
  static Session? _current;

  static Session? get current => _current;
  static set current(Session? session) {
    _current = session;

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

  static void clear() => _current = null;

  static Future<bool> loadFromFile() async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory directory = await getApplicationDocumentsDirectory();
    File file = File('${directory.path}/session.txt');
    if (!file.existsSync()) {
      return false;
    }

    String sessionKey = file.readAsStringSync();
    ServerResponse<Session> response = await serverGetSession(sessionKey);
    if (!response.success) {
      return false;
    }

    _current = response.value!;
    await Future.wait([
      serverGetCurrentUser(),
      serverGetCurrentTeam(),
    ]);
    return true;
  }

  /// The ID for the current session, which must be passed with every request
  final String key;
  final int user;
  final int team;

  /// The expiration time of this session
  DateTime expiration;

  Session({
    required this.key,
    required this.user,
    required this.team,
    required int expiration,
  }) : expiration = DateTime.fromMillisecondsSinceEpoch(expiration);

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

Future<ServerResponse<Session>> serverGetSession([String? sessionKey]) =>
    serverRequest(
      endpoint: '/session',
      method: 'GET',
      decoder: Session.fromJson,
      callback: (session) => Session.current = session,
      sessionKey: sessionKey,
    );
