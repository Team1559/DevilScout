final Uri serverURI = Uri.parse('http://localhost:8000');

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

  factory ServerResponse.errorFromJson(Map<String, dynamic> json) =>
      ServerResponse.error(json['error']);

  @override
  String toString() => (success ? value?.toString() : message) ?? 'null';
}

class Etag {
  String? _value;

  Map<String, String> get headers =>
      _value == null ? {} : {'If-None-Match': _value!};

  void update(Map<String, String> headers) => _value = headers['etag'] ?? _value;
  void clear() => _value = null;
}
