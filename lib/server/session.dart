import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'session.g.dart';

/// An authorized user session, containing user info as well as permissions
@JsonSerializable(createToJson: false)
class Session {
  static Session? current;

  static Map<String, String> get headers =>
      current == null ? {} : {'X-DS-SESSION-KEY': '${current!.id}'};

  /// The ID for the current session, which must be passed with every request
  final int id;

  /// The expiration time of this session
  DateTime expiration;

  Session({
    required this.id,
    required int expiration,
  }) : expiration = DateTime.fromMillisecondsSinceEpoch(expiration);

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}

Future<ServerResponse<Session>> serverGetSession() => serverRequest(
      endpoint: '/session',
      method: 'GET',
      decoder: Session.fromJson,
    ).then((response) {
      if (response.success && response.value != null) {
        Session.current = response.value!;
      }
      return response;
    });
