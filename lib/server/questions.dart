import 'dart:convert';

import 'package:http/http.dart';
import 'package:json_annotation/json_annotation.dart';

import 'server.dart';
import 'session.dart';
import 'users.dart';

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

@JsonSerializable()
class Question {
  final String prompt;
  final QuestionType type;
  final Map<String, Object>? config;

  Question(this.prompt, this.type, this.config);

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);

  Map<String, dynamic> toJson() => _$QuestionToJson(this);

  @override
  String toString() => json.encode(this);
}

@JsonSerializable()
class MatchQuestions {
  static MatchQuestions? _current;
  static final Etag _etag = Etag();

  static MatchQuestions get current => _current!;

  final List<Question> auto;
  final List<Question> teleop;
  final List<Question> endgame;
  final List<Question> general;
  final List<Question> human;

  MatchQuestions(
      this.auto, this.teleop, this.endgame, this.general, this.human);

  factory MatchQuestions.fromJson(Map<String, dynamic> json) =>
      _$MatchQuestionsFromJson(json);

  Map<String, dynamic> toJson() => _$MatchQuestionsToJson(this);

  @override
  String toString() => json.encode(this);
}

@JsonSerializable()
class PitQuestions {
  static PitQuestions? _current;
  static final Etag _etag = Etag();

  static PitQuestions get current => _current!;

  final List<Question> specs;
  final List<Question> auto;
  final List<Question> teleop;
  final List<Question> endgame;
  final List<Question> general;

  PitQuestions(this.specs, this.auto, this.teleop, this.endgame, this.general);

  factory PitQuestions.fromJson(Map<String, dynamic> json) =>
      _$PitQuestionsFromJson(json);

  Map<String, dynamic> toJson() => _$PitQuestionsToJson(this);

  @override
  String toString() => json.encode(this);
}

@JsonSerializable()
class DriveTeamQuestions {
  static DriveTeamQuestions? _current;
  static final Etag _etag = Etag();

  static DriveTeamQuestions get current => _current!;

  final List<Question> questions;

  DriveTeamQuestions(this.questions);

  factory DriveTeamQuestions.fromJson(Map<String, dynamic> json) =>
      _$DriveTeamQuestionsFromJson(json);

  Map<String, dynamic> toJson() => _$DriveTeamQuestionsToJson(this);

  @override
  String toString() => json.encode(this);
}

Future<ServerResponse<MatchQuestions>> downloadMatchQuestions() async {
  ServerResponse<Map<String, dynamic>> response = await _downloadQuestions(
      serverURI.resolve('/questions/match'), MatchQuestions._etag);

  if (!response.success) {
    return ServerResponse.error(response.message);
  }

  if (response.value == null) {
    return ServerResponse.success();
  }

  MatchQuestions._current = MatchQuestions.fromJson(response.value!);
  return ServerResponse.success(MatchQuestions.current);
}

Future<ServerResponse<PitQuestions>> downloadPitQuestions() async {
  ServerResponse<Map<String, dynamic>> response = await _downloadQuestions(
      serverURI.resolve('/questions/pit'), PitQuestions._etag);

  if (!response.success) {
    return ServerResponse.error(response.message);
  }

  if (response.value == null) {
    return ServerResponse.success();
  }

  PitQuestions._current = PitQuestions.fromJson(response.value!);
  return ServerResponse.success(PitQuestions.current);
}

Future<ServerResponse<DriveTeamQuestions>> downloadDriveTeamQuestions() async {
  if (User.current!.accessLevel < UserAccessLevel.admin) {
    return ServerResponse.error('Insufficient permissions');
  }

  ServerResponse<Map<String, dynamic>> response = await _downloadQuestions(
      serverURI.resolve('/questions/drive-team'), DriveTeamQuestions._etag);

  if (!response.success) {
    return ServerResponse.error(response.message);
  }

  if (response.value == null) {
    return ServerResponse.success();
  }

  DriveTeamQuestions._current = DriveTeamQuestions.fromJson(response.value!);
  return ServerResponse.success(DriveTeamQuestions.current);
}

Future<ServerResponse<Map<String, dynamic>>> _downloadQuestions(
    Uri uri, Etag etag) async {
  Request request = Request('GET', uri)
    ..headers.addAll(Session.current!.headers)
    ..headers.addAll(etag.headers);

  StreamedResponse response = await request.send();
  if (response.statusCode == 304) {
    return ServerResponse.success();
  }

  Map<String, dynamic> body =
      json.decode(await response.stream.bytesToString());
  if (response.statusCode != 200) {
    return ServerResponse.errorFromJson(body);
  }

  etag.update(response.headers);
  return ServerResponse.success(body);
}
