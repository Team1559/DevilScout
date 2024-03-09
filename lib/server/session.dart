import 'package:json_annotation/json_annotation.dart';

part 'session.g.dart';

/// An authorized user session
@JsonSerializable()
class Session {
  /// The current session, generated upon login
  static Session? current;

  /// Delete the current session (for logout). This should not be called by user
  /// code.
  static void clear() => current = null;

  /// The session key, a 128-bit UUID in the format
  /// 01234567-89ab-cdef-0123-456789abcdef, which must be passed to the server
  /// to authenticate each request.
  final String key;

  /// The user ID associated with this session
  final String user;

  /// The registered team number associated with this session.
  final int team;

  /// Constructs a Session, for deserializing JSON responses from the server.
  /// This should not be called from client code.
  Session({
    required this.key,
    required this.user,
    required this.team,
  });

  /// Constructs a Session from a JSON map. This should not be called from
  /// client code.
  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  Map<String, dynamic> toJson() => _$SessionToJson(this);
}
