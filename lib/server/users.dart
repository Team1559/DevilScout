import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'users.g.dart';

@JsonSerializable(createToJson: false)
class User {
  static User? currentUser;
  static final Etag _currentUserEtag = Etag();

  static List<User>? allUsers;
  static final Etag _allUsersEtag = Etag();

  final int id;
  final int team;
  final String username;
  final String fullName;
  final AccessLevel accessLevel;

  User({
    required this.id,
    required this.team,
    required this.username,
    required this.fullName,
    required this.accessLevel,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
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
/// **sudo** - Unhindered server management reserved for Team 1559 developers.
/// Abilities are quite extensive and not listed here.
@JsonEnum(valueField: 'value')
enum AccessLevel {
  user('USER'),
  admin('ADMIN'),
  sudo('SUDO');

  final String value;

  const AccessLevel(this.value);

  @override
  String toString() => value;

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

Future<ServerResponse<List<User>>> serverGetAllUsers() => serverRequest(
      endpoint: '/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
      etag: User._allUsersEtag,
    );

Future<ServerResponse<List<User>>> serverGetUsersOnTeam({required int team}) =>
    serverRequest(
      endpoint: '/team/$team/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
    );

Future<ServerResponse<User>> serverGetUser({required int id, Etag? etag}) =>
    serverRequest(
      endpoint: '/users/$id',
      method: 'GET',
      decoder: User.fromJson,
    );

Future<ServerResponse<User>> serverCreateUser({
  required String username,
  required String fullName,
  required int team,
  required AccessLevel accesslevel,
  required String password,
}) =>
    serverRequest(
      endpoint: '/users',
      method: 'POST',
      decoder: User.fromJson,
      payload: {
        'username': username,
        'fullName': fullName,
        'team': team,
        'accessLevel': accesslevel,
        'password': password,
      },
    );

Future<ServerResponse<User>> serverEditUser({
  required int id,
  String? username,
  String? fullName,
  AccessLevel? accessLevel,
  String? password,
}) {
  Map<String, dynamic> edits = {};

  if (username != null) {
    edits['username'] = username;
  }

  if (fullName != null) {
    edits['fullName'] = fullName;
  }

  if (accessLevel != null) {
    edits['accessLevel'] = accessLevel.value;
  }

  if (password != null) {
    edits['password'] = password;
  }

  return serverRequest(
    endpoint: '/users/$id',
    method: 'PATCH',
    decoder: User.fromJson,
    payload: edits,
  );
}

Future<ServerResponse<void>> serverDeleteUser({required int id}) =>
    serverRequest(endpoint: '/users/$id', method: 'DELETE');

Future<ServerResponse<User>> serverGetCurrentUser() => serverRequest(
      endpoint: '/users/${User.currentUser!.id}',
      method: 'GET',
      decoder: User.fromJson,
      callback: (user) => User.currentUser = user,
      etag: User._currentUserEtag,
    );

Future<ServerResponse<User>> serverEditCurrentUser({
  String? username,
  String? fullName,
  AccessLevel? accessLevel,
  String? password,
}) =>
    serverEditUser(
      id: User.currentUser!.id,
      username: username,
      fullName: fullName,
      accessLevel: accessLevel,
      password: password,
    ).then((response) {
      if (response.success && response.value != null) {
        User.currentUser = response.value;
      }
      return response;
    });

Future<ServerResponse<void>> serverDeleteCurrentUser() =>
    serverDeleteUser(id: User.currentUser!.id);
