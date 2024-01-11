import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

part 'users.g.dart';

@JsonSerializable(createToJson: false)
class User {
  static User? currentUser;
  static final Etag _currentUserEtag = Etag();

  static List<User> allUsers = List.empty();
  static final Etag _allUsersEtag = Etag();

  static void clear() {
    currentUser = null;
    _currentUserEtag.clear();

    allUsers = List.empty();
    _allUsersEtag.clear();
  }

  final String id;
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
      path: '/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
      etag: User._allUsersEtag,
    );

Future<ServerResponse<List<User>>> serverGetUsersOnTeam({required int team}) =>
    serverRequest(
      path: '/team/$team/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
    );

Future<ServerResponse<User>> serverGetUser({required int id, Etag? etag}) =>
    serverRequest(
      path: '/users/$id',
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
      path: '/users',
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
  required String id,
  String? username,
  String? fullName,
  AccessLevel? accessLevel,
  String? password,
}) =>
    serverRequest(
      path: '/users/$id',
      method: 'PATCH',
      decoder: User.fromJson,
      payload: {
        if (username != null) 'username': username,
        if (fullName != null) 'fullName': fullName,
        if (accessLevel != null) 'accessLevel': accessLevel.value,
        if (password != null) 'password': password,
      },
    );

Future<ServerResponse<void>> serverDeleteUser({required String id}) =>
    serverRequest(path: '/users/$id', method: 'DELETE');

Future<ServerResponse<User>> serverGetCurrentUser() => serverRequest(
      path: '/users/${Session.current!.user}',
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
    serverRequest(
      path: '/users/${Session.current!.user}',
      method: 'PATCH',
      decoder: User.fromJson,
      callback: (user) => User.currentUser = user,
      payload: {
        if (username != null) 'username': username,
        if (fullName != null) 'fullName': fullName,
        if (accessLevel != null) 'accessLevel': accessLevel.value,
        if (password != null) 'password': password,
      },
    );

Future<ServerResponse<void>> serverDeleteCurrentUser() =>
    serverDeleteUser(id: Session.current!.user);
