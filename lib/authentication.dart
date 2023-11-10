import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';
import 'package:hex/hex.dart';
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
// base64-encoded messages:
// - Client Login Request
// - Server Challenge
// - Client Authentication
// - Server Verification
//
// 1. Client Login Request
// The client receives the team number and username from the user. In addition,
// it randomly generates 8 bytes called the "client nonce". The client then
// sends the following message in a POST request to /login:
//
// t={team},n={username},r={client nonce as hex}
//
// 2. Server Challenge
// The server receives the Client Login Request, and parses the team number,
// username, and client nonce. It verifies that the requested user exists, and
// retrieves their password salt from a database. It then randomly generates
// 8 bytes of its own, and joins the two together to form the whole 16-byte
// "nonce". The server then responds with the following challenge:
//
// s={salt as hex},r={nonce as hex}
//
// 3. Client Authentication
// The client receives the Server Challenge, and parses the salt and nonce. It
// verifies the nonce begins with the client nonce it transmitted, and begins
// computing a proof of authentication. That process is as follows:
//
// passwordHash    = PBKDF2-SHA256(password, salt, 4096 iterations)
// clientKey       = HMAC-SHA256(passwordHash, "Client Key")
// storedKey       = SHA256(clientKey)
// clientSignature = HMAC-SHA256(storedKey, "{team number}{username}" + nonce)
// clientProof     = clientKey XOR clientSignature
//
// The client then sends the following message in a POST request to /auth:
//
// t={team},n={username},r={nonce as hex},p={clientProof as hex}
//
// The server receives the Client Authentication, and parses the team,
// username, nonce, and clientProof. It verifies the user against the database,
// verifies the nonce that it transmitted, and retrieves the dbStoredKey from
// the database. It then checks the clientProof by recomputing the storedKey
// and comparing it:
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
// following message:
//
// v={serverSignature as hex},i={sessionID},p={accessLevel},n={fullName}
//
// The client receives the Server Verification, and parses the serverSignature,
// sessionID, accessLevel, and fullName. It verifies the server signature by
// recomputing it:
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

Future<LoginStatus?> login(int team, String username) async {
  try {
    final List<int> clientNonce =
        List.generate(8, (index) => _random.nextInt(0x100), growable: false);
    final String clientNonceHex = _hexEncoder.convert(clientNonce);
    final String requestBody = 't=$team,n=$username,r=$clientNonceHex';
    final String requestBodyBase64 = base64.encode(utf8.encode(requestBody));

    final http.Response response =
        await http.post(_loginURI, body: requestBodyBase64);
    if (response.statusCode != 200) return null;

    final String responseBody = utf8.decode(base64.decode(response.body));
    if (responseBody.length != 53 ||
        !responseBody.startsWith('s=') ||
        responseBody.indexOf(',r=') != 18) {
      // invalid response format
      return null;
    }

    // ensure nonce has not been tampered with
    final String nonceHex = responseBody.substring(21);
    if (!nonceHex.startsWith(clientNonceHex)) return null;

    final List<int> salt = _hexDecoder.convert(responseBody.substring(2, 18));
    final List<int> nonce = _hexDecoder.convert(nonceHex);
    return LoginStatus._(team, username, salt, nonce);
  } catch (_) {
    return null;
  }
}

Future<Session?> authenticate(LoginStatus login, String password) async {
  try {
    final SecretKey saltedPassword =
        await _hashPassword(password: password, salt: login.salt);
    final List<int> clientKey = await _computeClientKey(saltedPassword);
    final List<int> storedKey = await _computeStoredKey(clientKey);
    final List<int> clientSignature = await _computeSignature(
        storedKey, login.team, login.username, login.nonce);
    final List<int> clientProof =
        _computeClientProof(clientKey, clientSignature);

    final String clientProofHex = _hexEncoder.convert(clientProof);
    final String nonceHex = _hexEncoder.convert(login.nonce);

    final String requestBody =
        't=${login.team},n=${login.username},r=$nonceHex,p=$clientProofHex';
    final String requestBodyBase64 = base64.encode(utf8.encode(requestBody));
    final Future<http.Response> serverRequest =
        http.post(_authURI, body: requestBodyBase64);

    final List<int> serverKey = await _computeServerKey(saltedPassword);
    final List<int> serverSignature = await _computeSignature(
        serverKey, login.team, login.username, login.nonce);
    final String serverSignatureHex = _hexEncoder.convert(serverSignature);

    final http.Response response = await serverRequest;
    if (response.statusCode != 200) return null;

    final String responseBody = utf8.decode(base64.decode(response.body));
    if (responseBody.length < 86 ||
        responseBody.length > 200 ||
        !responseBody.startsWith('v=') ||
        responseBody.indexOf(',i=') != 66 ||
        responseBody.indexOf(',p=') != 85 ||
        responseBody.indexOf(',n=') < 89) {
      // invalid response format
      return null;
    }

    // verify server's identity
    if (responseBody.substring(2, 66) != serverSignatureHex) return null;

    // parse information
    final String sessionID = responseBody.substring(69, 85);
    final String accessLevelStr =
        'UserAccessLevel.${responseBody.substring(88, responseBody.indexOf(',n='))}';
    final UserAccessLevel accessLevel = UserAccessLevel.values
        .firstWhere((l) => l.toString() == accessLevelStr);
    final String fullName =
        responseBody.substring(responseBody.indexOf(',n=') + 3);

    return Session._(
        login.team, login.username, fullName, accessLevel, sessionID);
  } catch (_) {
    return null;
  }
}

// End exposed API, begin internal implementation

const _hexEncoder = HexEncoder();
const _hexDecoder = HexDecoder();
final _random = Random.secure();

final Uri _loginURI = Uri.parse('http://10.0.2.2:80/login');
final Uri _authURI = Uri.parse('http://10.0.2.2:80/auth');

final List<int> _clientKeyBytes = utf8.encode('Client Key');
final List<int> _serverKeyBytes = utf8.encode('Server Key');

final Sha256 _sha256 = Sha256();
final Hmac _hmacSha256 = Hmac(_sha256);
final Pbkdf2 _pbkdf2Sha256 = Pbkdf2(
  macAlgorithm: _hmacSha256,
  iterations: 4096,
  bits: 256,
);

Future<SecretKey> _hashPassword(
        {required String password, required List<int> salt}) async =>
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
    List.generate(32, (index) => clientKey[index] ^ clientSignature[index]);
