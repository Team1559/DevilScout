import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'users.dart';

part 'teams.g.dart';

@JsonSerializable(createToJson: false)
class Team {
  static Team? currentTeam;
  static final Etag _currentTeamEtag = Etag();

  static List<Team> allTeams = List.empty();
  static final Etag _allTeamsEtag = Etag();

  static void clear() {
    currentTeam = null;
    _currentTeamEtag.clear();

    allTeams = List.empty();
    _allTeamsEtag.clear();
  }

  final int number;
  final String name;
  final String eventKey;

  bool get hasEventKey => eventKey != '';

  Team({
    required this.number,
    required this.name,
    required this.eventKey,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

Future<ServerResponse<List<Team>>> serverGetAllTeams() => serverRequest(
      endpoint: '/teams',
      method: 'GET',
      decoder: listOf(Team.fromJson),
      etag: Team._allTeamsEtag,
    );

Future<ServerResponse<Team>> serverGetTeam({required int number, Etag? etag}) =>
    serverRequest(
      endpoint: '/teams/$number',
      method: 'GET',
      decoder: Team.fromJson,
    );

Future<ServerResponse<Team>> serverCreateTeam({
  required int number,
  required String name,
}) =>
    serverRequest(
      endpoint: '/teams',
      method: 'POST',
      decoder: Team.fromJson,
      payload: {
        'number': number,
        'name': name,
      },
    );

Future<ServerResponse<Team>> serverEditTeam({
  required int number,
  String? name,
  String? eventKey,
  Etag? etag,
}) {
  Map<String, dynamic> edits = {};

  if (name != null) {
    edits['name'] = name;
  }

  if (eventKey != null) {
    edits['eventKey'] = eventKey;
  }

  return serverRequest(
    endpoint: '/teams/$number',
    method: 'PATCH',
    decoder: Team.fromJson,
    payload: edits,
    etag: etag,
  );
}

Future<ServerResponse<void>> serverDeleteTeam({required int number}) =>
    serverRequest(endpoint: '/teams/$number', method: 'DELETE');

Future<ServerResponse<Team>> serverGetCurrentTeam() {
  if (User.currentUser == null) {
    return Future.value(
      ServerResponse.error('Missing user'),
    );
  }

  return serverRequest(
    endpoint: '/teams/${User.currentUser!.team}',
    method: 'GET',
    decoder: Team.fromJson,
    callback: (team) => Team.currentTeam = team,
    etag: Team._currentTeamEtag,
  );
}

Future<ServerResponse<Team>> serverEditCurrentTeam({
  String? name,
  String? eventKey,
}) {
  if (User.currentUser == null) {
    return Future.value(
      ServerResponse.error('Missing user'),
    );
  }

  return serverEditTeam(
    number: User.currentUser!.team,
    name: name,
    eventKey: eventKey,
    etag: Team._currentTeamEtag,
  ).then((response) {
    if (response.success && response.value != null) {
      Team.currentTeam = response.value;
    }
    return response;
  });
}
