import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// This file implements a custom client-server authentication protocol based on
// SCRAM, or Salted Challenge Response Authentication Mechanism. The purpose of
// the protocol is to guard against network snooping: even if an attacker
// obtains a valid clientProof during a transaction, it is useless without the
// storedKey because the proof changes with every login attempt. This is the
// idea behind a challenge-response protocol.
//
// This particular mechanism also has the added benefit of performing mutual
// authentication, meaning not only does the server authenticate the client,
// but the client authenticates the server. The transfer is split into four
// JSON-encoded messages:
// - Client Login Request
// - Server Challenge
// - Client Authentication
// - Server Verification
//
// 1. Client Login Request
// The client receives the team number and username from the user. In addition,
// it randomly generates 8 bytes called the "client nonce". The client then
// sends the team, username, and client nonce in a POST request to /login.
//
// 2. Server Challenge
// The server receives the Client Login Request, verifies that the requested
// user exists, and retrieves their password salt from a database. It then
// randomly generates 8 bytes of its own, and joins the two together to form
// the whole 16-byte "nonce". The server then responds with a challenge
// containing the salt and nonce.
//
// 3. Client Authentication
// The client receives the Server Challenge, verifies the nonce begins with the
// client nonce it transmitted, and begins computing a proof of authentication.
// That process is as follows:
//
// passwordHash    = PBKDF2-SHA256(password, salt, 4096 iterations)
// clientKey       = HMAC-SHA256(passwordHash, "Client Key")
// storedKey       = SHA256(clientKey)
// clientSignature = HMAC-SHA256(storedKey, "{team number}{username}" + nonce)
// clientProof     = clientKey XOR clientSignature
//
// The client then sends team, username, nonce, and clientProof in a POST request to
// /auth.
//
// The server receives the Client Authentication, verifies the user against the
// database, verifies the nonce that it transmitted, and retrieves the
// dbStoredKey from the database. It then checks the clientProof by recomputing
// the storedKey and comparing it:
//
// clientSignature = HMAC-SHA256(dbStoredKey, "{team number}{username}" + nonce)
// clientKey       = clientProof XOR clientSignature
// storedKey       = SHA256(clientKey)
//
// If storedKey and dbStoredKey are the same, this proves that the client is in
// possession of clientKey, which can only be obtained from passwordHash.
//
// 4. Server Verification
// Now that the server has certified the client's identity, it must now prove
// its identity. It retrieves the serverKey from the database, and computes the
// serverSignature:
//
// serverSignature = HMAC-SHA256(serverKey, "{team number}{username}" + nonce)
//
// It also generates a session for the user, and responds to the client with the
// server signature, sessionID, accessLevel, and fullName.
//
// The client receives the Server Verification, and verifies the server
// signature by recomputing it:
//
// serverKey       = HMAC-SHA256(passwordHash, "Server Key")
// serverSignature = HMAC-SHA256(serverKey, "{team number}{username}" + nonce)
//
// If the two are equal, this proves the server is in possession of serverKey,
// which could only have been obtained from passwordHash upon registration.

/// Maintains the state of the login between entering team, username and password
class LoginStatus {
  /// A randomly generated 16-byte value (8 bytes from the client, 8 bytes from the server)
  final List<int> nonce;

  /// An 8-byte salt stored on the server, used for securely hashing users' passwords
  final List<int> salt;

  /// The user's team number, in the range [1,9999]
  final int team;

  /// The user's username, up to 32 characters
  final String username;

  LoginStatus._(this.team, this.username, this.salt, this.nonce);
}

/// An authorized user session, containing user info as well as permissions
class Session {
  /// The user's team number (e.g. 1559)
  final int team;

  /// The user's informal username (e.g. xander)
  final String username;

  /// The user's full registered name (e.g. Xander Bhalla)
  final String fullName;

  /// The level of access the server granted the user
  final UserAccessLevel accessLevel;

  /// The ID for the current session, which must be passed with every request
  final String sessionID;

  Session._(this.team, this.username, this.fullName, this.accessLevel,
      this.sessionID);
}

/// A user's permission to access resources on the server. If a client attempts
/// to exceed their access level, the server will reject their request. The
/// three access levels are as follows:
///
/// **standard** - Granted to all authenticated members. Abilities include:
/// - submitting match & pit scouting data to the server
/// - accessing the various data analysis pages
/// - modifying their account information, preferences, password, etc.
///
/// **admin** - Granted to team administrators, which may include coaches,
/// mentors, team captains, or drive team members. Registered teams must have
/// at least one admin, but no more than 6. In addition to standard access,
/// abilities include:
/// - setting the team's current competition
/// - submitting drive team post-match feedback
/// - adding, removing, and disabling team members
/// - resetting team members' passwords
///
/// **sudo** - Reserved for server managers on Team 1559. In addition to admin
/// access, superuser abilities include:
/// - managing registered teams
/// - changing any standard or admin users' passwords
/// - halting all network access to the server
enum UserAccessLevel {
  standard,
  admin,
  sudo;

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

Future<LoginStatus?> login({required int team, required String username}) async {
  try {
    return await _login(team, username);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<Session?> authenticate({required LoginStatus login, required String password}) async {
  try {
    return await _authenticate(login, password);
  } catch (e) {
    print(e);
    return null;
  }
}

Future<bool> logout(Session session) async {
  try {
    return await _logout(session);
  } catch (e) {
    print(e);
    return false;
  }
}

// End exposed API, begin internal implementation
const String _sessionsURI = 'http://10.0.2.2:80/sessions';
final Uri _logoutURI = Uri.parse(_sessionsURI);
final Uri _loginURI = Uri.parse('$_sessionsURI/login');
final Uri _authURI = Uri.parse('$_sessionsURI/auth');

final List<int> _clientKeyBytes = utf8.encode('Client Key');
final List<int> _serverKeyBytes = utf8.encode('Server Key');

final Random _random = Random.secure();

final Sha256 _sha256 = Sha256();
final Hmac _hmacSha256 = Hmac(_sha256);
final Pbkdf2 _pbkdf2Sha256 = Pbkdf2(
  macAlgorithm: _hmacSha256,
  iterations: 4096,
  bits: 256,
);

Future<LoginStatus?> _login(int team, String username) async {
  final List<int> clientNonce =
      List.generate(8, (index) => _random.nextInt(0x100), growable: false);
  final String clientNonceBase64 = base64.encode(clientNonce);
  final String requestBody =
      '{"team":$team,"username":"$username","clientNonce":"$clientNonceBase64"}';

  final http.Response response = await http.post(_loginURI, body: requestBody);
  if (response.statusCode != 200) return null;
  final Map<String, dynamic> responseJson = json.decode(response.body);

  // ensure nonce has not been tampered with
  final List<int> nonce = base64.decode(responseJson['nonce']);
  if (!listEquals(clientNonce, nonce.sublist(0, 8))) return null;

  final List<int> salt = base64.decode(responseJson['salt']);
  return LoginStatus._(team, username, salt, nonce);
}

Future<Session?> _authenticate(LoginStatus login, String password) async {
  final SecretKey saltedPassword = await _hashPassword(password, login.salt);
  final List<int> clientKey = await _computeClientKey(saltedPassword);
  final List<int> storedKey = await _computeStoredKey(clientKey);
  final List<int> clientSignature = await _computeSignature(
      storedKey, login.team, login.username, login.nonce);
  final List<int> clientProof = _computeClientProof(clientKey, clientSignature);

  final Future<http.Response> serverRequest = http.post(_authURI,
      body:
          '{"team":${login.team},"username":"${login.username}","nonce":"${base64.encode(login.nonce)}","clientProof":"${base64.encode(clientProof)}"}');

  final List<int> serverKey = await _computeServerKey(saltedPassword);
  final List<int> serverSignature = await _computeSignature(
      serverKey, login.team, login.username, login.nonce);

  final http.Response response = await serverRequest;
  if (response.statusCode != 200) return null;
  final Map<String, dynamic> responseJson = json.decode(response.body);

  // verify server's identity
  final List<int> serverSignatureResponse =
      base64.decode(responseJson['serverSignature']);
  if (!listEquals(serverSignature, serverSignatureResponse)) return null;

  // parse information
  final String accessLevelStr =
      'UserAccessLevel.${responseJson['accessLevel'].toLowerCase()}';
  final UserAccessLevel accessLevel =
      UserAccessLevel.values.firstWhere((l) => l.toString() == accessLevelStr);

  return Session._(login.team, login.username, responseJson['fullName'],
      accessLevel, responseJson['sessionID']);
}

Future<bool> _logout(Session session) async {
  final http.Response response = await http
      .delete(_logoutURI, headers: {'X_DS_SESSION_KEY': session.sessionID});
  return response.statusCode == 200;
}

Future<SecretKey> _hashPassword(String password, List<int> salt) async =>
    _pbkdf2Sha256.deriveKeyFromPassword(password: password, nonce: salt);

Future<List<int>> _computeKey(
        SecretKey saltedPassword, List<int> keyBytes) async =>
    (await _hmacSha256.calculateMac(keyBytes, secretKey: saltedPassword)).bytes;

Future<List<int>> _computeClientKey(SecretKey saltedPassword) async =>
    await _computeKey(saltedPassword, _clientKeyBytes);

Future<List<int>> _computeStoredKey(List<int> clientKey) async =>
    (await _sha256.hash(clientKey)).bytes;

Future<List<int>> _computeServerKey(SecretKey saltedPassword) async =>
    await _computeKey(saltedPassword, _serverKeyBytes);

Future<List<int>> _computeSignature(
        List<int> key, int team, String username, List<int> nonce) async =>
    (await _hmacSha256.calculateMac(utf8.encode('$team$username') + nonce,
            secretKey: SecretKey(key)))
        .bytes;

List<int> _computeClientProof(List<int> clientKey, List<int> clientSignature) =>
    List.generate(32, (index) => clientKey[index] ^ clientSignature[index], growable: false);
