import '/server/server.dart';

/// Submit match data to the server in the format defined by match questions.
Future<ServerResponse<void>> serverSubmitMatchData({
  required String matchKey,
  required int team,
  required Map<String, Map<String, dynamic>> data,
}) =>
    serverRequest(
      path: 'submissions/match/$matchKey/$team',
      method: 'POST',
      payload: data,
    );

/// Submit pit data to the server in the format defined by pit questions.
Future<ServerResponse<void>> serverSubmitPitData({
  required String eventKey,
  required int team,
  required Map<String, Map<String, dynamic>> data,
}) =>
    serverRequest(
      path: 'submissions/pit/$eventKey/$team',
      method: 'POST',
      payload: data,
    );

/// Submit drive team feedback data to the server. [partners] should have team
/// numbers as string keys, and the question-defined response format as its
/// body.
Future<ServerResponse<void>> serverSubmitDriveTeamData({
  required String matchKey,
  required Map<String, Map<String, dynamic>> partners,
}) =>
    serverRequest(
      path: 'submissions/drive-team/$matchKey',
      method: 'POST',
      payload: partners,
    );
