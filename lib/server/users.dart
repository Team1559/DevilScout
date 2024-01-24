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

  /// Whether the user is an administrator with additional privileges
  @JsonKey(name: 'admin')
  final bool isAdmin;

  /// Constructs a User, for deserializing JSON responses from the server. This
  /// should not be called from client code.
  User({
    required this.id,
    required this.team,
    required this.username,
    required this.fullName,
    required this.isAdmin,
  });

  /// Constructs a User from a JSON map. This should not be called from client
  /// code.
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

/// Get the list of registered users on your team. Requires ADMIN.
Future<ServerResponse<List<User>>> serverGetUsers() => serverRequest(
      path: 'teams/${Session.current!.team}/users',
      method: 'GET',
      decoder: listOf(User.fromJson),
    );

/// Get a user. Requires ADMIN if not the same user.
Future<ServerResponse<User>> serverGetUser({required String id, Etag? etag}) =>
    serverRequest(
      path: 'users/$id',
      method: 'GET',
      decoder: User.fromJson,
      etag: etag,
    );

/// Register a new user. Requires ADMIN.
Future<ServerResponse<User>> serverCreateUser({
  required String username,
  required String fullName,
  required String password,
  bool isAdmin = false,
}) =>
    serverRequest(
      path: 'teams/${Session.current!.team}/users',
      method: 'POST',
      decoder: User.fromJson,
      payload: {
        'username': username,
        'fullName': fullName,
        'admin': isAdmin,
        'password': password,
        'team': Session.current!.team,
      },
    );

/// Edit a user. Omit fields that should not be modified. Requires ADMIN if not
/// the same user.
Future<ServerResponse<User>> serverEditUser({
  required String id,
  String? username,
  String? fullName,
  bool? isAdmin,
  String? password,
}) =>
    serverRequest(
      path: 'users/$id',
      method: 'PATCH',
      decoder: User.fromJson,
      payload: {
        if (username != null) 'username': username,
        if (fullName != null) 'fullName': fullName,
        if (isAdmin != null) 'admin': isAdmin,
        if (password != null) 'password': password,
      },
    );

/// Delete a registered user. Requires ADMIN if not the same user.
Future<ServerResponse<void>> serverDeleteUser({required String id}) =>
    serverRequest(
      path: 'users/$id',
      method: 'DELETE',
    );

/// Get the user associated with the current session. Prefer this over
/// [serverGetUser] for the current user.
Future<ServerResponse<User>> serverGetCurrentUser() => serverRequest(
      path: 'users/${Session.current!.user}',
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
  bool? isAdmin,
  String? password,
}) =>
    serverRequest(
      path: 'users/${Session.current!.user}',
      method: 'PATCH',
      decoder: User.fromJson,
      callback: (user) => User.currentUser = user,
      etag: User._currentUserEtag,
      payload: {
        if (username != null) 'username': username,
        if (fullName != null) 'fullName': fullName,
        if (isAdmin != null) 'admin': isAdmin,
        if (password != null) 'password': password,
      },
    );

/// Delete the current user. This will inherently destroy the current login
/// session. This should be preferred over [serverDeleteUser] for the current
/// user.
Future<ServerResponse<void>> serverDeleteCurrentUser() =>
    serverDeleteUser(id: Session.current!.user);
