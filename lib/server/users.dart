import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

part 'users.g.dart';

/// A registered user on the server
@JsonSerializable(createToJson: false)
class User {
  /// The current user's information, if authenticated
  static User? currentUser;
  static final Etag _currentUserEtag = Etag();

  /// The list of all registered users, after request via [serverGetAllUsers]
  static List<User> allUsers = List.empty();
  static final Etag _allUsersEtag = Etag();

  /// Erase all cached user information (for logout)
  static void clear() {
    currentUser = null;
    _currentUserEtag.clear();

    allUsers = List.empty();
    _allUsersEtag.clear();
  }

  /// A 128-bit UUID in the format 01234567-89ab-cdef-0123-456789abcdef,
  /// identifying the user to the server
  final String id;

  /// The team number the user belongs to, in the range 1 to 9999
  final int team;

  /// The user's username, used for login, e.g. 'xander'
  final String username;

  /// The user's full or display name, e.g. 'Xander Bhalla'
  final String fullName;

  /// The user's level of access, as provided by the server. The server
  /// regulates access to each endpoint, ensuring users cannot exceed this
  /// limit.
  final AccessLevel accessLevel;

  /// Constructs a User, for deserializing JSON responses from the server. This
  /// should not be called from client code.
  User({
    required this.id,
    required this.team,
    required this.username,
    required this.fullName,
    required this.accessLevel,
  });

  /// Constructs a User from a JSON map. This should not be called from client
  /// code.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// A user's permission to access resources on the server. If a client attempts
/// to exceed their access level, the server will reject their request.
@JsonEnum(valueField: 'value')
enum AccessLevel {
  /// Granted to all authenticated members. Abilities include:
  /// - submitting match, pit, and drive team scouting data to the server
  /// - accessing the various data analysis pages
  /// - modifying/deleting account information, preferences, password, etc.
  user('USER'),

  /// Granted to team administrators, which may include coaches,
  /// mentors, team captains, or drive team members. Registered teams must have
  /// at least one admin, but no more than 6. In addition to standard access,
  /// abilities include:
  /// - changing the team's information (including current event)
  /// - adding, removing, or disabling team members
  /// - editing team member information or passwords
  admin('ADMIN'),

  /// Unhindered server management reserved for Team 1559 developers.
  /// Abilities are quite extensive and not listed here.
  sudo('SUDO');

  /// The JSON representation of this enum
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

/// Get the list of all registered users. Requires SUDO.
Future<ServerResponse<List<User>>> serverGetAllUsers() => serverRequest(
      path: '/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
      etag: User._allUsersEtag,
    );

/// Get the list of registered users on a team. Requires ADMIN, or SUDO if on a
/// different team.
Future<ServerResponse<List<User>>> serverGetUsersOnTeam({required int team}) =>
    serverRequest(
      path: '/team/$team/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
    );

/// Get a user. Requires ADMIN if not the same user, or SUDO if on a different
/// team.
Future<ServerResponse<User>> serverGetUser({required int id, Etag? etag}) =>
    serverRequest(
      path: '/users/$id',
      method: 'GET',
      decoder: User.fromJson,
    );

/// Register a new user. Requires ADMIN, or SUDO if on a different team.
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

/// Edit a user. Omit fields that should not be modified. Requires ADMIN if not
/// the same user, and SUDO if on a different team.
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

/// Delete a registered user. Requires ADMIN if not the same user, and SUDO if
/// on a different team.
Future<ServerResponse<void>> serverDeleteUser({required String id}) =>
    serverRequest(path: '/users/$id', method: 'DELETE');

/// Get the user associated with the current session. Prefer this over
/// [serverGetUser] for the current user.
Future<ServerResponse<User>> serverGetCurrentUser() => serverRequest(
      path: '/users/${Session.current!.user}',
      method: 'GET',
      decoder: User.fromJson,
      callback: (user) => User.currentUser = user,
      etag: User._currentUserEtag,
    );

/// Edit the current user. Prefer this over [serverGetUser] for the current
/// user.
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
      etag: User._currentUserEtag,
      payload: {
        if (username != null) 'username': username,
        if (fullName != null) 'fullName': fullName,
        if (accessLevel != null) 'accessLevel': accessLevel.value,
        if (password != null) 'password': password,
      },
    );

/// Delete the current user. This will inherently destroy the current login
/// session. This should be preferred over [serverDeleteUser] for the current
/// user.
Future<ServerResponse<void>> serverDeleteCurrentUser() =>
    serverDeleteUser(id: Session.current!.user);
