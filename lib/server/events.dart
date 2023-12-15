import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'events.g.dart';

@JsonSerializable(createToJson: false)
class Event {
  static Event? currentEvent;
  static final Etag _currentEventEtag = Etag();

  static List<Event>? allEvents;
  static final Etag _allEventsEtag = Etag();

  final String key;
  final String name;
  final String location;

  final DateTime start;
  final DateTime end;

  Event({
    required this.key,
    required this.name,
    required this.location,
    required this.start,
    required this.end,
  });

  factory Event.fromJson(Map<String, dynamic> json) =>
      _$EventInfoFromJson(json);
}

@JsonSerializable(createToJson: false)
class FrcTeam {
  static List<FrcTeam>? currentEventTeams;
  static final Etag _currentEventTeamsEtag = Etag();

  final int number;
  final String name;
  final String location;

  FrcTeam({
    required this.number,
    required this.name,
    required this.location,
  });

  factory FrcTeam.fromJson(Map<String, dynamic> json) =>
      _$EventTeamFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventMatch {
  static List<EventMatch>? currentEventSchedule;
  static final Etag _currentEventScheduleEtag = Etag();

  final String key;
  final MatchLevel level;
  final int set;
  final DateTime time;
  final bool completed;

  @JsonKey(name: 'match')
  final int number;

  @JsonKey(name: 'blue')
  final List<int> blueAlliance;

  @JsonKey(name: 'red')
  final List<int> redAlliance;

  EventMatch({
    required this.key,
    required this.level,
    required this.set,
    required this.number,
    required int time,
    required this.completed,
    required this.blueAlliance,
    required this.redAlliance,
  }) : time = DateTime.fromMillisecondsSinceEpoch(time);

  factory EventMatch.fromJson(Map<String, dynamic> json) =>
      _$EventMatchFromJson(json);
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

Future<ServerResponse<List<Event>>> serverGetAllEvents() => serverRequest(
      endpoint: '/events',
      method: 'GET',
      decoder: listOf(Event.fromJson),
      etag: Event._allEventsEtag,
      callback: (events) => Event.allEvents = events,
    );

Future<ServerResponse<Event>> serverGetEvent({
  required String eventKey,
  Etag? etag,
}) =>
    serverRequest(
      endpoint: '/events/$eventKey',
      method: 'GET',
      decoder: Event.fromJson,
      etag: etag,
    );

Future<ServerResponse<List<EventMatch>>> serverGetEventSchedule({
  required String eventKey,
  Etag? etag,
}) =>
    serverRequest(
      endpoint: '/events/$eventKey/match-schedule',
      method: 'GET',
      decoder: listOf(EventMatch.fromJson),
      etag: etag,
    );

Future<ServerResponse<List<FrcTeam>>> serverGetEventTeamList({
  required String eventKey,
  Etag? etag,
}) =>
    serverRequest(
      endpoint: '/events/$eventKey/teams',
      method: 'GET',
      decoder: listOf(FrcTeam.fromJson),
    );

Future<ServerResponse<Event>> serverGetCurrentEvent() => serverRequest(
      endpoint: '/events/${Event.currentEvent!.key}',
      method: 'GET',
      decoder: Event.fromJson,
      callback: (event) => Event.currentEvent = event,
      etag: Event._currentEventEtag,
    );

Future<ServerResponse<List<EventMatch>>> serverGetCurrentEventSchedule() =>
    serverRequest(
      endpoint: '/events/${Event.currentEvent!.key}/match-schedule',
      method: 'GET',
      decoder: listOf(EventMatch.fromJson),
      callback: (schedule) => EventMatch.currentEventSchedule = schedule,
      etag: EventMatch._currentEventScheduleEtag,
    );

Future<ServerResponse<List<FrcTeam>>> serverGetCurrentEventTeamList() =>
    serverRequest(
      endpoint: '/events/${Event.currentEvent!.key}/teams',
      method: 'GET',
      decoder: listOf(FrcTeam.fromJson),
      callback: (teams) => FrcTeam.currentEventTeams = teams,
      etag: FrcTeam._currentEventTeamsEtag
    );
