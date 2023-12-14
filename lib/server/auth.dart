import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';
import 'teams.dart';
import 'users.dart';

part 'auth.g.dart';

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

class _LoginStatus {
  static _LoginStatus? current;

  final int team;
  final String username;
  final _LoginChallenge challenge;

  _LoginStatus({
    required this.team,
    required this.username,
    required this.challenge,
  });
}

@JsonSerializable(createToJson: false)
class _LoginChallenge {
  final List<int> nonce;
  final List<int> salt;

  _LoginChallenge({
    required String nonce,
    required String salt,
  })  : nonce = base64.decode(nonce),
        salt = base64.decode(salt);

  // ignore: unused_element
  factory _LoginChallenge.fromJson(Map<String, dynamic> json) =>
      _$LoginChallengeFromJson(json);
}

@JsonSerializable(createToJson: false)
class _AuthResponse {
  final User user;
  final Team team;
  final Session session;
  final List<int> serverSignature;

  _AuthResponse({
    required this.user,
    required this.team,
    required this.session,
    required String serverSignature,
  }) : serverSignature = base64.decode(serverSignature);

  factory _AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

final Random _random = Random.secure();

final Sha256 _sha256 = Sha256();
final Hmac _hmacSha256 = Hmac(_sha256);
final Pbkdf2 _pbkdf2Sha256 = Pbkdf2(
  macAlgorithm: _hmacSha256,
  iterations: 4096,
  bits: 256,
);

/// Attempt to initiate a login to the server for the given user. Returns null
/// if successful, else an error message for the user.
Future<ServerResponse<void>> serverLogin({
  required int team,
  required String username,
}) async {
  List<int> clientNonce =
      List.generate(8, (index) => _random.nextInt(0x100), growable: false);

  ServerResponse<_LoginChallenge> response = await serverRequest(
    endpoint: '/login',
    method: 'POST',
    decoder: _LoginChallenge.fromJson,
    payload: {
      'team': team,
      'username': username,
      'clientNonce': base64.encode(clientNonce)
    },
  );

  if (!response.success) {
    return response;
  }

  _LoginChallenge challenge = response.value!;
  for (int i = 0; i < 8; i++) {
    if (clientNonce[i] != challenge.nonce[i]) {
      return ServerResponse.error('Server modified nonce');
    }
  }

  _LoginStatus.current = _LoginStatus(
    team: team,
    username: username,
    challenge: challenge,
  );
  return ServerResponse.success();
}

/// After receiving the login challenge, attempt to authenticate the user by
/// completing the challenge with the given password. Returns null if
/// successful, else an error message for the user.
Future<ServerResponse<void>> serverAuthenticate({
  required String password,
}) async {
  if (_LoginStatus.current == null) {
    return ServerResponse.error('No previous login attempt');
  }
  _LoginStatus login = _LoginStatus.current!;

  SecretKey saltedPassword = await _pbkdf2Sha256.deriveKeyFromPassword(
    password: password,
    nonce: login.challenge.salt,
  );
  List<int> clientKey = await _computeKey(saltedPassword, 'Client Key');
  List<int> storedKey = (await _sha256.hash(clientKey)).bytes;

  List<int> clientSignature = await _computeSignature(
    storedKey,
    login.team,
    login.username,
    login.challenge.nonce,
  );
  List<int> clientProof = [
    for (int i = 0; i < 32; i++) clientKey[i] ^ clientSignature[i]
  ];

  Future<ServerResponse<_AuthResponse>> request = serverRequest(
    endpoint: '/auth',
    method: 'POST',
    decoder: _AuthResponse.fromJson,
    payload: {
      'team': login.team,
      'username': login.username,
      'nonce': base64.encode(login.challenge.nonce),
      'clientProof': base64.encode(clientProof)
    },
  );

  List<int> serverKey = await _computeKey(saltedPassword, 'Server Key');
  List<int> serverSignature = await _computeSignature(
    serverKey,
    login.team,
    login.username,
    login.challenge.nonce,
  );

  ServerResponse<_AuthResponse> response = await request;
  if (!response.success) {
    return response;
  }

  _AuthResponse auth = response.value!;
  for (int i = 0; i < 32; i++) {
    if (serverSignature[i] != auth.serverSignature[i]) {
      return ServerResponse.error('Failed to authenticate server');
    }
  }

  _LoginStatus.current = null;
  Session.current = auth.session;
  User.currentUser = auth.user;
  Team.currentTeam = auth.team;

  return ServerResponse.success();
}

/// Log out the current session, if it exists.
Future<ServerResponse<void>> serverLogout() =>
    serverRequest(endpoint: '/logout', method: 'DELETE');

Future<List<int>> _computeKey(SecretKey saltedPassword, String name) =>
    _hmacSha256
        .calculateMac(
          utf8.encode(name),
          secretKey: saltedPassword,
        )
        .then((key) => key.bytes);

Future<List<int>> _computeSignature(
  List<int> key,
  int team,
  String username,
  List<int> nonce,
) =>
    _hmacSha256
        .calculateMac(
          utf8.encode('$team$username') + nonce,
          secretKey: SecretKey(key),
        )
        .then((signature) => signature.bytes);
