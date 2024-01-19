import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';

part 'teams.g.dart';

/// A registered scouting team on the server
@JsonSerializable(createToJson: false)
class Team {
  /// The current team's information, if authenticated
  static Team? currentTeam;
  static final Etag _currentTeamEtag = Etag();

  /// The list of all registered teams, after request via [serverGetAllTeams]
  static List<Team> allTeams = List.empty();
  static final Etag _allTeamsEtag = Etag();

  /// Erase all cached team information (for logout)
  static void clear() {
    currentTeam = null;
    _currentTeamEtag.clear();

    allTeams = List.empty();
    _allTeamsEtag.clear();
  }

  /// The team's FRC number (e.g. 1559)
  final int number;

  /// The team's name, as it exists in the database
  final String name;

  /// The TBA event key of the event the team is attending. The team may not be
  /// attending an event, in which case this is an empty string.
  final String eventKey;

  /// Whether the team is attending an event. Equivalent to checking [eventKey] != ''.
  bool get hasEventKey => eventKey != '';

  /// Constructs a Team, for deserializing JSON responses from the server. This
  /// should not be called from client code.
  Team({
    required this.number,
    required this.name,
    required this.eventKey,
  });

  /// Constructs a Team from a JSON map. This should not be called from client
  /// code.
  factory Team.fromJson(Map<String, dynamic> json) => _$TeamFromJson(json);
}

/// Get the current team's information. Prefer this over [serverGetTeam] for the
/// current team.
Future<ServerResponse<Team>> serverGetCurrentTeam() => serverRequest(
      path: 'teams/${Session.current!.team}',
      method: 'GET',
      decoder: Team.fromJson,
      callback: (team) => Team.currentTeam = team,
      etag: Team._currentTeamEtag,
    );

/// Edit the current team's information. Prefer this over [serverEditTeam] for
/// the current team. Requires ADMIN.
Future<ServerResponse<Team>> serverEditCurrentTeam({
  String? name,
  String? eventKey,
}) =>
    serverRequest(
      path: 'teams/${Session.current!.team}',
      method: 'PATCH',
      decoder: Team.fromJson,
      etag: Team._currentTeamEtag,
      callback: (team) => Team.currentTeam = team,
      payload: {
        if (name != null) 'name': name,
        if (eventKey != null) 'eventKey': eventKey,
      },
    );
