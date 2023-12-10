import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'session.g.dart';

/// An authorized user session, containing user info as well as permissions
@JsonSerializable()
class Session {
  static Session? current;

  /// The ID for the current session, which must be passed with every request
  final int id;

  /// The expiration time of this session
  DateTime expiration;

  Session({required this.id, required int expiration})
      : expiration = DateTime.fromMillisecondsSinceEpoch(expiration);

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);

  @override
  String toString() => json.encode(_$SessionToJson(this));

  Map<String, String> get headers => {'X-DS-SESSION-KEY': '$id'};

  Future<ServerResponse<void>> refresh() async {
    Request request = Request('GET', serverURI.resolve('/session'))
      ..headers.addAll(headers);

    StreamedResponse response = await request.send();
    Map<String, dynamic> body =
        json.decode(await response.stream.bytesToString());

    if (response.statusCode != 200) {
      return ServerResponse.errorFromJson(body);
    }

    Session session = Session.fromJson(body);
    assert(session.id == id);

    expiration = session.expiration;
    return ServerResponse.success();
  }
}
