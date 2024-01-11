import 'server.dart';

Future<ServerResponse<void>> serverSubmitMatchData({
  required String eventKey,
  required String matchKey,
  required int team,
  required Map<String, Map<String, dynamic>> data,
}) =>
    serverRequest(
      path: '/submissions/match-scouting',
      method: 'POST',
      payload: {
        'event': eventKey,
        'match': matchKey,
        'team': team,
        'data': data
      },
    );

Future<ServerResponse<void>> serverSubmitPitData({
  required String eventKey,
  required int team,
  required Map<String, Map<String, dynamic>> data,
}) =>
    serverRequest(
      path: '/submissions/pit-scouting',
      method: 'POST',
      payload: {
        'event': eventKey,
        'team': team,
        'data': data,
      },
    );

Future<ServerResponse<void>> serverSubmitDriveTeamData({
  required String eventKey,
  required String matchKey,
  required Map<String, Map<String, dynamic>> data,
}) =>
    serverRequest(
      path: '/submissions/drive-team-scouting',
      method: 'POST',
      payload: {
        'event': eventKey,
        'match': matchKey,
        'partners': data,
      },
    );
