import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

part 'users.g.dart';

@JsonSerializable()
class User {
  static User? current;
  static final Etag _currentEtag = Etag();

  final int id;
  final int team;
  final String username;
  final String fullName;
  final UserAccessLevel accessLevel;

  User(this.id, this.team, this.username, this.fullName, this.accessLevel);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() => json.encode(this);
}

/// A user's permission to access resources on the server. If a client attempts
/// to exceed their access level, the server will reject their request. The
/// three access levels are as follows:
///
/// **user** - Granted to all authenticated members. Abilities include:
/// - submitting match & pit scouting data to the server
/// - accessing the various data analysis pages
/// - modifying their account information, preferences, password, etc.
///
/// **admin** - Granted to team administrators, which may include coaches,
/// mentors, team captains, or drive team members. Registered teams must have
/// at least one admin, but no more than 6. In addition to standard access,
/// abilities include:
/// - submitting drive team post-match feedback
/// - setting the team's current event
/// - adding, removing, or disabling team members
/// - resetting team members' passwords
///
/// **sudo** - Unhindered server management reserved for Team 1559. Abilities
/// not listed here.
@JsonEnum(valueField: 'value')
enum UserAccessLevel {
  user('USER'),
  admin('ADMIN'),
  sudo('SUDO');

  final String value;

  const UserAccessLevel(this.value);

  bool operator >(other) {
    return index > other.index;
  }

  bool operator <(other) {
    return index < other.index;
  }

  bool operator >=(other) {
    return index >= other.index;
  }

  bool operator <=(other) {
    return index <= other.index;
  }
}

Future<ServerResponse<User>> downloadCurrentUser() async {
  ServerResponse<User> response =
      await downloadUser(User.current!.id, User._currentEtag);

  if (!response.success) return response;
  if (response.value == null) return ServerResponse.success(User.current);

  User.current = response.value!;
  return response;
}

Future<ServerResponse<User>> downloadUser(int id, [Etag? etag]) async {
  Request request = Request('GET', serverURI.resolve('/users/$id'))
    ..headers.addAll(Session.current!.headers);

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success();
  }

  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  if (response.statusCode != 200) {
    return ServerResponse.errorFromJson(body);
  }

  User user = User.fromJson(body);

  if (etag != null) {
    etag.update(response.headers);
  }

  return ServerResponse.success(user);
}

Future<ServerResponse<List<User>>> downloadAllUsers() async {
  Request request = Request('GET', serverURI.resolve('/users'))
    ..headers.addAll(Session.current!.headers);

  StreamedResponse response = await request.send();
  String body = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    return ServerResponse.error(body);
  }

  List<User> users = (json.decode(body) as List<dynamic>)
      .map((e) => User.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);

  return ServerResponse.success(users);
}
