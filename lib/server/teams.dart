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

Future<ServerResponse<List<Team>>> serverGetAllTeams() => serverRequestList(
      endpoint: '/teams',
      method: 'GET',
      decoder: Team.fromJson,
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
  );
}

Future<ServerResponse<void>> serverDeleteTeam({required int number}) =>
    serverRequest(endpoint: '/teams/$number', method: 'DELETE');

Future<ServerResponse<Team>> serverGetCurrentTeam() => serverGetTeam(
      number: Team.currentTeam!.number,
      etag: Team._currentTeamEtag,
    ).then((response) {
      if (response.success && response.value != null) {
        Team.currentTeam = response.value;
      }
      return response;
    });

Future<ServerResponse<Team>> serverEditCurrentTeam({
  String? name,
  String? eventKey,
}) =>
    serverEditTeam(
      number: Team.currentTeam!.number,
      name: name,
      eventKey: eventKey,
    ).then((response) {
      if (response.success && response.value != null) {
        Team.currentTeam = response.value;
      }
      return response;
    });
