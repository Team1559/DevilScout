import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'questions.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum QuestionType {
  boolean,
  counter,
  grid,
  multiple,
  number,
  range,
  sequence,
  single;
}

@JsonSerializable(createToJson: false)
class Question {
  final String prompt;
  final QuestionType type;
  final Map<String, Object>? config;

  Question({
    required this.prompt,
    required this.type,
    required this.config,
  });

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}

@JsonSerializable(createToJson: false)
class MatchQuestions {
  static MatchQuestions? current;
  static final Etag _etag = Etag();

  static void clear() {
    current = null;
    _etag.clear();
  }

  final List<Question> auto;
  final List<Question> teleop;
  final List<Question> endgame;
  final List<Question> general;
  final List<Question> human;

  MatchQuestions({
    required this.auto,
    required this.teleop,
    required this.endgame,
    required this.general,
    required this.human,
  });

  factory MatchQuestions.fromJson(Map<String, dynamic> json) =>
      _$MatchQuestionsFromJson(json);
}

@JsonSerializable(createToJson: false)
class PitQuestions {
  static PitQuestions? current;
  static final Etag _etag = Etag();

  static void clear() {
    current = null;
    _etag.clear();
  }

  final List<Question> specs;
  final List<Question> auto;
  final List<Question> teleop;
  final List<Question> endgame;
  final List<Question> general;

  PitQuestions({
    required this.specs,
    required this.auto,
    required this.teleop,
    required this.endgame,
    required this.general,
  });

  factory PitQuestions.fromJson(Map<String, dynamic> json) =>
      _$PitQuestionsFromJson(json);
}

@JsonSerializable(createToJson: false)
class DriveTeamQuestions {
  static DriveTeamQuestions? current;
  static final Etag _etag = Etag();

  static void clear() {
    current = null;
    _etag.clear();
  }

  final List<Question> questions;

  DriveTeamQuestions({required this.questions});

  factory DriveTeamQuestions.fromJson(Map<String, dynamic> json) =>
      _$DriveTeamQuestionsFromJson(json);
}

Future<ServerResponse<MatchQuestions>> serverGetMatchQuestions() =>
    serverRequest(
      endpoint: '/questions/match',
      method: 'GET',
      decoder: MatchQuestions.fromJson,
      etag: MatchQuestions._etag,
    );

Future<ServerResponse<PitQuestions>> serverGetPitQuestions() => serverRequest(
      endpoint: '/questions/pit',
      method: 'GET',
      decoder: PitQuestions.fromJson,
      etag: PitQuestions._etag,
    );

Future<ServerResponse<DriveTeamQuestions>> serverGetDriveTeamQuestions() =>
    serverRequest(
      endpoint: '/questions/drive-team',
      method: 'GET',
      decoder: DriveTeamQuestions.fromJson,
      etag: DriveTeamQuestions._etag,
    );
