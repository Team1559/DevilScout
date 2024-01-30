import 'dart:convert';

import 'package:http/http.dart';

import '/server/session.dart';

/// A response from the Devil Scout Server. Responses return in one of three states:
///
/// - Success, in which [value] contains the requested data
/// - Cached/empty, in which [success] is still true, but [value] is null
/// - Error, in which [message] describes what happened
///
/// This class should not be instantiated by client code.
class ServerResponse<T> {
  final bool success;
  final T? value;
  final String? message;

  /// Constructs a non-error server response, possibly with data in [value]
  ServerResponse.success([this.value])
      : success = true,
        message = null;

  /// Constructs a server error with a message
  ServerResponse.error(this.message)
      : success = false,
        value = null;

  /// Constructs a server error directly from the JSON response
  factory ServerResponse.errorFromJson(String json) =>
      ServerResponse.error(json.isEmpty ? null : jsonDecode(json)['error']);

  @override
  String toString() {
    if (success) {
      return value?.runtimeType.toString() ?? '[Success, no value]';
    } else {
      return message ?? '[Error, no message]';
    }
  }
}

/// An HTTP etag, used to determine whether cached data needs to be refreshed.
class Etag {
  String? _value;

  Map<String, String> get _headers =>
      _value == null ? {} : {'If-None-Match': _value!};

  void _update(Map<String, String> headers) =>
      _value = headers['etag'] ?? _value;

  /// Clear this etag. This forces the next request to invalidate cached data.
  void clear() => _value = null;
}

final Uri _serverApiUri =
    Uri.parse('https://scouting.victorrobotics.org/api/v1/');
final Client _httpClient = Client();

/// A generic method to access a server API endpoint. Clients are recommended
/// to use the dedicated methods provided in this directory.
///
/// The only mandatory parameters are [path] and [method]. This will work for
/// GET or POST requests. The remaining parameters are used in a variety of
/// situations:
///
/// - [decoder] If present, the response JSON will be decoded using this
/// function. Typically, this is a fromJson constructor. If omitted, the
/// response JSON will be ignored (except for errors).
/// - [callback] If present, a function to call when the result is ready.
/// This requires [decoder].
/// - [etag] If present, the [Etag] to update based on response headers.
/// - [payload] If present, an object to encode as JSON and send in the body of
/// the request. This is required for POST or PATCH requests. The object must be
/// encodable via [jsonEncode].
///
/// See other files in this directory for sample usage.
Future<ServerResponse<R>> serverRequest<R, T>({
  required String path,
  required String method,
  R Function(T)? decoder,
  void Function(R)? callback,
  Etag? etag,
  Object? payload,
}) async {
  Request request = Request(method, _serverApiUri.resolve(path));

  if (Session.current != null) {
    request.headers.addAll({'X-DS-SESSION-KEY': Session.current!.key});
  }

  if (etag != null) {
    request.headers.addAll(etag._headers);
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
    if (response.headers['content-type']?.contains('json') ?? false) {
      String body = await response.stream.bytesToString();
      return ServerResponse.errorFromJson(body);
    }
    return ServerResponse.error('Error contacting server, try again');
  } else if (decoder == null || response.statusCode == 304) {
    return ServerResponse.success();
  }

  String body = await response.stream.bytesToString();
  R result = decoder(jsonDecode(body));

  etag?._update(response.headers);
  callback?.call(result);
  return ServerResponse.success(result);
}

/// A helper to transform a JSON decoder for a class into a JSON decoder for a
/// list of that class.
///
/// Example:
/// ```dart
/// serverRequest(
///   ...
///   decoder: listOf(QuestionConfig.fromJson),
/// )
/// ```
List<R> Function(List<dynamic>) listOf<R, T>(R Function(T) decoder) =>
    (List<dynamic> list) =>
        list.map((e) => e as T).map(decoder).toList(growable: false);
