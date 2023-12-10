import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

part 'events.g.dart';

@JsonSerializable()
class EventInfo {
  static List<EventInfo> list = List.empty();
  static final Etag _listEtag = Etag();

  static EventInfo? current;
  static final Etag _currentEtag = Etag();

  final String key;
  final String name;
  final String location;

  final DateTime start;
  final DateTime end;

  EventInfo(this.key, this.name, this.location, this.start, this.end);

  factory EventInfo.fromJson(Map<String, dynamic> json) =>
      _$EventInfoFromJson(json);

  @override
  String toString() => json.encode(_$EventInfoToJson(this));
}

@JsonSerializable()
class TeamInfo {
  static List<TeamInfo>? currentList;
  static final Etag _etag = Etag();

  final int number;
  final String name;
  final String location;

  TeamInfo(this.number, this.name, this.location);

  factory TeamInfo.fromJson(Map<String, dynamic> json) =>
      _$TeamInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TeamInfoToJson(this);

  @override
  String toString() => json.encode(this);
}

@JsonSerializable()
class MatchInfo {
  static List<MatchInfo>? _schedule;
  static final Etag _scheduleEtag = Etag();
  static List<MatchInfo> get schedule => _schedule!;
  static void clearCurrent() => _schedule = null;

  final String key;
  final MatchLevel level;
  final int set;
  final int match;

  @JsonKey(name: 'blue')
  final List<int> blueAlliance;

  @JsonKey(name: 'red')
  final List<int> redAlliance;

  MatchInfo(this.key, this.level, this.set, this.match, this.blueAlliance,
      this.redAlliance);

  factory MatchInfo.fromJson(Map<String, dynamic> json) =>
      _$MatchInfoFromJson(json);

  Map<String, dynamic> toJson() => _$MatchInfoToJson(this);

  @override
  String toString() => json.encode(this);
}

@JsonEnum(valueField: 'value')
enum MatchLevel {
  qualification('QUAL'),
  quarterfinals('QUARTER'),
  semifinals('SEMI'),
  finals('FINAL'),
  unknown('UNKNOWN');

  final String value;

  const MatchLevel(this.value);
}

Future<ServerResponse<EventInfo>> downloadCurrentEvent(
    [String? eventKey]) async {
  if (eventKey == null) {
    eventKey = EventInfo.current!.key;
  } else {
    EventInfo._currentEtag.clear();
  }

  ServerResponse<EventInfo> response =
      await downloadEvent(eventKey, EventInfo._currentEtag);

  if (!response.success) return response;
  if (response.value == null) {
    return ServerResponse.success(EventInfo.current);
  }

  EventInfo.current = response.value;
  return response;
}

Future<ServerResponse<List<MatchInfo>>> downloadCurrentMatchSchedule(
    [String? eventKey]) async {
  if (eventKey == null) {
    eventKey = EventInfo.current!.key;
  } else {
    MatchInfo._scheduleEtag.clear();
  }

  ServerResponse<List<MatchInfo>> response =
      await downloadMatchSchedule(eventKey, MatchInfo._scheduleEtag);

  if (!response.success) return response;
  if (response.value == null) {
    return ServerResponse.success(MatchInfo.schedule);
  }

  MatchInfo._schedule = response.value;
  return response;
}

Future<ServerResponse<List<TeamInfo>>> downloadCurrentTeamList(
    [String? eventKey]) async {
  if (eventKey == null) {
    eventKey = EventInfo.current!.key;
  } else {
    TeamInfo._etag.clear();
  }

  ServerResponse<List<TeamInfo>> response =
      await downloadTeamList(eventKey, TeamInfo._etag);

  if (!response.success) return response;
  if (response.value == null) {
    return ServerResponse.success(TeamInfo.currentList);
  }

  TeamInfo.currentList = response.value;
  return response;
}

Future<ServerResponse<EventInfo>> downloadEvent(String eventKey,
    [Etag? etag]) async {
  if (!RegExp(r'20\d{2}[a-z]{3,5}').hasMatch(eventKey)) {
    return ServerResponse.error('Invalid event key format');
  }

  Request request = Request('GET', serverURI.resolve('/events/$eventKey'))
    ..headers.addAll(Session.current!.headers);

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success();
  }

  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  if (response.statusCode != 200) {
    return ServerResponse.errorFromJson(body);
  }

  EventInfo event = EventInfo.fromJson(body);
  assert(event.key == eventKey);

  if (etag != null) {
    etag.update(response.headers);
  }

  return ServerResponse.success(event);
}

Future<ServerResponse<List<MatchInfo>>> downloadMatchSchedule(String eventKey,
    [Etag? etag]) async {
  if (!RegExp(r'20\d{2}[a-z]{3,5}').hasMatch(eventKey)) {
    return ServerResponse.error('Invalid event key format');
  }

  Request request =
      Request('GET', serverURI.resolve('/events/$eventKey/match-schedule'))
        ..headers.addAll(Session.current!.headers);

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success();
  }

  String bodyStr = await response.stream.bytesToString();
  if (response.statusCode != 200) {
    Map<String, dynamic> body =
        json.decode(await response.stream.bytesToString());
    return ServerResponse.errorFromJson(body);
  }

  List<MatchInfo> matches = (json.decode(bodyStr) as List<dynamic>)
      .map((e) => e as Map<String, dynamic>)
      .map(MatchInfo.fromJson)
      .toList(growable: false);

  if (etag != null) {
    etag.update(response.headers);
  }

  return ServerResponse.success(matches);
}

Future<ServerResponse<List<TeamInfo>>> downloadTeamList(String eventKey,
    [Etag? etag]) async {
  if (!RegExp(r'20\d{2}[a-z]{3,5}').hasMatch(eventKey)) {
    return ServerResponse.error('Invalid event key format');
  }

  Request request = Request('GET', serverURI.resolve('/events/$eventKey/teams'))
    ..headers.addAll(Session.current!.headers);

  if (etag != null) {
    request.headers.addAll(etag.headers);
  }

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success();
  }

  String bodyStr = await response.stream.bytesToString();
  if (response.statusCode != 200) {
    Map<String, dynamic> body =
        json.decode(await response.stream.bytesToString());
    return ServerResponse.errorFromJson(body);
  }

  List<TeamInfo> teams = (json.decode(bodyStr) as List<dynamic>)
      .map((e) => TeamInfo.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);

  if (etag != null) {
    etag.update(response.headers);
  }

  return ServerResponse.success(teams);
}

Future<ServerResponse<List<EventInfo>>> downloadEventList() async {
  Request request = Request('GET', serverURI.resolve('/events'))
    ..headers.addAll(Session.current!.headers)
    ..headers.addAll(EventInfo._listEtag.headers);

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success(EventInfo.list);
  }

  String body = await response.stream.bytesToString();
  if (response.statusCode != 200) {
    return ServerResponse.errorFromJson(json.decode(body));
  }

  EventInfo.list = (json.decode(body) as List<dynamic>)
      .map((e) => EventInfo.fromJson(e as Map<String, dynamic>))
      .toList(growable: false);
  EventInfo._listEtag.update(response.headers);

  return ServerResponse.success(EventInfo.list);
}
