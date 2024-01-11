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
      ServerResponse.error(json.isEmpty ? null : jsonDecode(json)['error']);

  @override
  String toString() {
    if (success) {
      return value?.toString() ?? '[Success, no value]';
    } else {
      return message ?? '[Error, no message]';
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

final Uri _serverUri = Uri.parse('http://localhost:8000');
final Client _httpClient = Client();

Future<ServerResponse<R>> serverRequest<R, T>({
  required String path,
  required String method,
  R Function(T)? decoder,
  void Function(R)? callback,
  Etag? etag,
  Object? payload,
}) async {
  Request request = Request(method, _serverUri.resolve(path));

  if (Session.current != null) {
    request.headers.addAll({'X-DS-SESSION-KEY': Session.current!.key});
  }

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  if (payload != null) {
    request.headers['Content-Type'] = 'application/json';
    request.body = jsonEncode(payload);
  }

  StreamedResponse response;
  try {
    response = await _httpClient.send(request);
  } on ClientException {
    return ServerResponse.error('Error contacting server, try again');
  }

  if (response.statusCode >= 400) {
    String body = await response.stream.bytesToString();
    return ServerResponse.errorFromJson(body);
  } else if (decoder == null || response.statusCode == 304) {
    return ServerResponse.success();
  }

  String body = await response.stream.bytesToString();
  R result = decoder.call(jsonDecode(body));

  etag?.update(response.headers);
  callback?.call(result);
  return ServerResponse.success(result);
}

List<R> Function(List<dynamic>) listOf<R, T>(R Function(T) decoder) =>
    (List<dynamic> list) =>
        list.map((e) => e as T).map(decoder).toList(growable: false);
