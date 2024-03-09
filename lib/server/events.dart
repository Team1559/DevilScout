import 'package:json_annotation/json_annotation.dart';

import '/server/server.dart';
import '/server/session.dart';
import '/server/teams.dart';

part 'events.g.dart';

@JsonSerializable(createToJson: false)
class Event {
  static Event? current;
  static final Etag _currentEventEtag = Etag();

  static List<Event> allEvents = List.empty();
  static final Etag _allEventsEtag = Etag();

  static void clear() {
    current = null;
    _currentEventEtag.clear();

    allEvents = List.empty();
    _allEventsEtag.clear();
  }

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

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);
}

@JsonSerializable(createToJson: false)
class FrcTeam {
  static List<FrcTeam> currentEventTeams = List.empty();
  static final Etag _currentEventTeamsEtag = Etag();

  static void clear() {
    currentEventTeams = List.empty();
    _currentEventTeamsEtag.clear();
  }

  final int number;
  final String name;
  final String location;

  FrcTeam({
    required this.number,
    required this.name,
    required this.location,
  });

  factory FrcTeam.fromJson(Map<String, dynamic> json) =>
      _$FrcTeamFromJson(json);
}

@JsonSerializable(createToJson: false)
class EventMatch {
  static List<EventMatch> currentEventSchedule = List.empty();
  static List<EventMatch> currentTeamSchedule = List.empty();
  static final Etag _currentEventScheduleEtag = Etag();

  static void clear() {
    currentEventSchedule = List.empty();
    currentTeamSchedule = List.empty();
    _currentEventScheduleEtag.clear();
  }

  final String key;
  final String name;
  final MatchLevel level;
  final int set;
  final int number;
  final DateTime time;
  final bool completed;
  final List<int> blue;
  final List<int> red;

  EventMatch({
    required this.key,
    required this.name,
    required this.level,
    required this.set,
    required this.number,
    required int time,
    required this.completed,
    required this.blue,
    required this.red,
  }) : time = DateTime.fromMillisecondsSinceEpoch(time);

  factory EventMatch.fromJson(Map<String, dynamic> json) =>
      _$EventMatchFromJson(json);

  bool containsTeam(int team) => blue.contains(team) || red.contains(team);

  int compareTo(EventMatch other) {
    if (completed != other.completed) {
      return completed ? 1 : -1;
    }

    if (level != other.level) {
      return level.index - other.level.index;
    }

    if (set != other.set) {
      return set - other.set;
    }

    if (number != other.number) {
      return number - other.number;
    }

    return time.compareTo(other.time);
  }
}

@JsonEnum(valueField: '_json')
enum MatchLevel {
  qualification('QUAL', 'Qualification'),
  quarterfinals('QUARTER', 'Quarterfinal'),
  semifinals('SEMI', 'Semifinal'),
  finals('FINAL', 'Final'),
  unknown('UNKNOWN', 'Custom');

  // ignore: unused_field
  final String _json;
  final String _toString;

  const MatchLevel(this._json, this._toString);

  @override
  String toString() => _toString;
}

Future<ServerResponse<List<Event>>> serverGetAllEvents() => serverRequest(
      path: 'events',
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
      path: 'events/$eventKey',
      method: 'GET',
      decoder: Event.fromJson,
      etag: etag,
    );

Future<ServerResponse<List<EventMatch>>> serverGetEventSchedule({
  required String eventKey,
  Etag? etag,
}) =>
    serverRequest(
      path: 'events/$eventKey/matches',
      method: 'GET',
      decoder: listOf(EventMatch.fromJson),
      etag: etag,
    );

Future<ServerResponse<List<FrcTeam>>> serverGetEventTeamList({
  required String eventKey,
  Etag? etag,
}) =>
    serverRequest(
      path: 'events/$eventKey/teams',
      method: 'GET',
      decoder: listOf(FrcTeam.fromJson),
    );

Future<ServerResponse<Event>> serverGetCurrentEvent() {
  if (Team.current.eventKey == '') {
    return Future.value(
      ServerResponse.error(message: 'Missing team/eventKey'),
    );
  }

  return serverRequest(
    path: 'events/${Team.current.eventKey}',
    method: 'GET',
    decoder: Event.fromJson,
    callback: (event) => Event.current = event,
    etag: Event._currentEventEtag,
  );
}

Future<ServerResponse<List<EventMatch>>> serverGetCurrentEventSchedule() {
  if (Team.current.eventKey == '') {
    return Future.value(
      ServerResponse.error(message: 'Missing team/eventKey'),
    );
  }

  return serverRequest(
    path: 'events/${Team.current.eventKey}/matches',
    method: 'GET',
    decoder: listOf(EventMatch.fromJson),
    callback: (schedule) {
      EventMatch.currentEventSchedule = schedule;
      EventMatch.currentTeamSchedule = List.of(
        schedule.where((match) => match.containsTeam(Session.current!.team)),
        growable: false,
      );
    },
    etag: EventMatch._currentEventScheduleEtag,
  );
}

Future<ServerResponse<List<FrcTeam>>> serverGetCurrentEventTeamList() {
  if (Team.current.eventKey == '') {
    return Future.value(
      ServerResponse.error(message: 'Missing team/eventKey'),
    );
  }

  return serverRequest(
    path: 'events/${Team.current.eventKey}/teams',
    method: 'GET',
    decoder: listOf(FrcTeam.fromJson),
    callback: (teams) => FrcTeam.currentEventTeams = teams,
    etag: FrcTeam._currentEventTeamsEtag,
  );
}
