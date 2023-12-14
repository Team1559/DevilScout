import 'dart:convert';

import 'package:http/http.dart';

import 'session.dart';

class ServerResponse<T> {
  final bool success;
  final T? value;
  final String? message;

  ServerResponse.success([this.value])
      : success = true,
        message = null;

  ServerResponse.error(this.message)
      : success = false,
        value = null;

  factory ServerResponse.errorFromJson(String json) =>
      ServerResponse.error(jsonDecode(json)['error']);

  @override
  String toString() {
    if (success) {
      return value?.toString() ?? 'null';
    } else {
      return message ?? 'Error';
    }
  }
}

class Etag {
  String? _value;

  Map<String, String> get headers =>
      _value == null ? {} : {'If-None-Match': _value!};

  void update(Map<String, String> headers) =>
      _value = headers['etag'] ?? _value;
  void clear() => _value = null;
}

final Uri _serverURI = Uri.parse('http://localhost:8000');

Future<ServerResponse<R>> serverRequest<R, T>({
  required String endpoint,
  required String method,
  R Function(T)? decoder,
  Object? payload,
  Etag? etag,
}) async {
  Request request = Request(method, _serverURI.resolve(endpoint))
    ..headers.addAll(Session.headers);

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  if (payload != null) {
    request.body = jsonEncode(payload);
  }

  StreamedResponse response = await request.send();
  String bodyStr = await response.stream.bytesToString();
  if (response.statusCode >= 400) {
    return ServerResponse.errorFromJson(bodyStr);
  }

  if (decoder == null) {
    return ServerResponse.success();
  }

  dynamic body = jsonDecode(bodyStr);
  R result = decoder.call(body);
  return ServerResponse.success(result);
}

Future<ServerResponse<List<R>>> serverRequestList<R, T>({
  required String endpoint,
  required String method,
  required R Function(T) decoder,
  Object? payload,
  Etag? etag,
}) =>
    serverRequest(
      endpoint: endpoint,
      method: method,
      decoder: (List<dynamic> list) =>
          list.map((e) => e as T).map(decoder).toList(growable: false),
      payload: payload,
      etag: etag,
    );
