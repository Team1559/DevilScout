import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

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
      path: '/teams',
      method: 'GET',
      decoder: listOf(Team.fromJson),
      etag: Team._allTeamsEtag,
    );

Future<ServerResponse<Team>> serverGetTeam({required int number, Etag? etag}) =>
    serverRequest(
      path: '/teams/$number',
      method: 'GET',
      decoder: Team.fromJson,
    );

Future<ServerResponse<Team>> serverCreateTeam({
  required int number,
  required String name,
}) =>
    serverRequest(
      path: '/teams',
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
}) =>
    serverRequest(
      path: '/teams/$number',
      method: 'PATCH',
      decoder: Team.fromJson,
      etag: etag,
      payload: {
        if (name != null) 'name': name,
        if (eventKey != null) 'eventKey': eventKey,
      },
    );

Future<ServerResponse<void>> serverDeleteTeam({required int number}) =>
    serverRequest(
      path: '/teams/$number',
      method: 'DELETE',
    );

Future<ServerResponse<Team>> serverGetCurrentTeam() => serverRequest(
      path: '/teams/${Session.current!.team}',
      method: 'GET',
      decoder: Team.fromJson,
      callback: (team) => Team.currentTeam = team,
      etag: Team._currentTeamEtag,
    );

Future<ServerResponse<Team>> serverEditCurrentTeam({
  String? name,
  String? eventKey,
}) =>
    serverRequest(
      path: '/teams/${Session.current!.team}',
      method: 'PATCH',
      decoder: Team.fromJson,
      etag: Team._currentTeamEtag,
      callback: (team) => Team.currentTeam = team,
      payload: {
        if (name != null) 'name': name,
        if (eventKey != null) 'eventKey': eventKey,
      },
    );
