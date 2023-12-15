import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'teams.g.dart';

@JsonSerializable(createToJson: false)
class Team {
  static Team? currentTeam;
  static final Etag _currentTeamEtag = Etag();

  static List<Team> allTeams = List.empty();
  static final Etag _allTeamsEtag = Etag();

  final int number;
  final String name;
  final String eventKey;

  Team({
    required this.number,
    required this.name,
    required this.eventKey,
  });

  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

@JsonSerializable(
  includeIfNull: false,
  createFactory: false,
)
class TeamEdits {
  final int number;
  final String? name;
  final String? eventKey;

  TeamEdits({
    required this.number,
    required this.name,
    required this.eventKey,
  });

  Map<String, dynamic> toJson() => _$TeamEditsToJson(this);
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

Future<ServerResponse<Team>> serverGetCurrentTeam() => serverRequest(
      endpoint: '/teams/${Team.currentTeam!.number}',
      method: 'GET',
      decoder: Team.fromJson,
      callback: (team) => Team.currentTeam = team,
      etag: Team._currentTeamEtag,
    );

Future<ServerResponse<Team>> serverEditCurrentTeam({
  String? name,
  String? eventKey,
}) =>
    serverEditTeam(
      number: Team.currentTeam!.number,
      name: name,
      eventKey: eventKey,
      etag: Team._currentTeamEtag,
    ).then((response) {
      if (response.success && response.value != null) {
        Team.currentTeam = response.value;
      }
      return response;
    });
