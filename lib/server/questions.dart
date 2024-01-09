import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'questions.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum QuestionType {
  boolean(_$BooleanConfigFromJson),
  counter(_$CounterConfigFromJson),
  multiple(_$MultipleChoiceConfigFromJson),
  number(_$NumberConfigFromJson),
  range(_$RangeConfigFromJson),
  sequence(_$SequenceConfigFromJson),
  single(_$SingleChoiceConfigFromJson);

  final QuestionConfig Function(Map<String, dynamic>) parser;

  const QuestionType(this.parser);
}

abstract class QuestionConfig {
  static List<QuestionPage> matchQuestions = List.empty();
  static List<QuestionPage> pitQuestions = List.empty();
  static List<QuestionConfig> driveTeamQuestions = List.empty();

  static final Etag _matchQuestionsEtag = Etag();
  static final Etag _pitQuestionsEtag = Etag();
  static final Etag _driveTeamQuestionsEtag = Etag();

  static void clear() {
    matchQuestions = List.empty();
    pitQuestions = List.empty();
    driveTeamQuestions = List.empty();

    _matchQuestionsEtag.clear();
    _pitQuestionsEtag.clear();
    _driveTeamQuestionsEtag.clear();
  }

  final String prompt;
  final String key;

  const QuestionConfig({
    required this.prompt,
    required this.key,
  });

  factory QuestionConfig.fromJson(Map<String, dynamic> json) =>
      $enumDecode(_$QuestionTypeEnumMap, json['type']).parser.call(json);
}

@JsonSerializable(createToJson: false)
class BooleanConfig extends QuestionConfig {
  BooleanConfig({
    required super.prompt,
    required super.key,
  });
}

@JsonSerializable(createToJson: false)
class CounterConfig extends QuestionConfig {
  CounterConfig({
    required super.prompt,
    required super.key,
  });
}

@JsonSerializable(createToJson: false)
class MultipleChoiceConfig extends QuestionConfig {
  final List<String> options;

  MultipleChoiceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

@JsonSerializable(createToJson: false)
class NumberConfig extends QuestionConfig {
  final int min;
  final int max;

  NumberConfig({
    required super.prompt,
    required super.key,
    required this.min,
    required this.max,
  });
}

@JsonSerializable(createToJson: false)
class RangeConfig extends QuestionConfig {
  final int min;
  final int max;
  final int increment;

  RangeConfig({
    required super.prompt,
    required super.key,
    required this.min,
    required this.max,
    this.increment = 1,
  });
}

@JsonSerializable(createToJson: false)
class SequenceConfig extends QuestionConfig {
  final List<String> options;

  SequenceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

@JsonSerializable(createToJson: false)
class SingleChoiceConfig extends QuestionConfig {
  final List<String> options;

  SingleChoiceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

@JsonSerializable(createToJson: false)
class QuestionPage {
  final String key;
  final String title;
  final List<QuestionConfig> questions;

  QuestionPage({
    required this.key,
    required this.title,
    required this.questions,
  });

  factory QuestionPage.fromJson(Map<String, dynamic> json) =>
      _$QuestionPageFromJson(json);

  QuestionPage driveTeam(String newKey, String newTitle) =>
      QuestionPage(key: newKey, title: newTitle, questions: questions);
}

Future<ServerResponse<List<QuestionPage>>> serverGetMatchQuestions() =>
    serverRequest(
      endpoint: '/questions/match',
      method: 'GET',
      decoder: listOf(QuestionPage.fromJson),
      callback: (questions) => QuestionConfig.matchQuestions = questions,
      etag: QuestionConfig._matchQuestionsEtag,
    );

Future<ServerResponse<List<QuestionPage>>> serverGetPitQuestions() =>
    serverRequest(
      endpoint: '/questions/pit',
      method: 'GET',
      decoder: listOf(QuestionPage.fromJson),
      callback: (questions) => QuestionConfig.pitQuestions = questions,
      etag: QuestionConfig._pitQuestionsEtag,
    );

Future<ServerResponse<List<QuestionConfig>>> serverGetDriveTeamQuestions() =>
    serverRequest(
      endpoint: '/questions/drive-team',
      method: 'GET',
      decoder: listOf(QuestionConfig.fromJson),
      callback: (questions) => QuestionConfig.driveTeamQuestions = questions,
      etag: QuestionConfig._driveTeamQuestionsEtag,
    );
