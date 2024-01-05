import 'package:json_annotation/json_annotation.dart';

import 'server.dart';

part 'questions.g.dart';

@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum QuestionType {
  boolean(_$BooleanConfigFromJson),
  counter(_$CounterConfigFromJson),
  grid(_$GridConfigFromJson),
  multiple(_$MultipleChoiceConfigFromJson),
  number(_$NumberInputConfigFromJson),
  range(_$NumberRangeConfigFromJson),
  sequence(_$SequenceConfigFromJson),
  single(_$SingleChoiceConfigFromJson);

  final QuestionConfig Function(Map<String, dynamic>) configParser;

  const QuestionType(this.configParser);
}

class Question {
  static List<QuestionPage> matchQuestions = List.empty();
  static List<QuestionPage> pitQuestions = List.empty();
  static List<Question> driveTeamQuestions = List.empty();

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
  final QuestionType type;
  final QuestionConfig config;

  const Question({
    required this.prompt,
    required this.type,
    required this.config,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    String prompt = json['prompt'];
    QuestionType type = $enumDecode(_$QuestionTypeEnumMap, json['type']);
    QuestionConfig config = type.configParser.call(json['config'] ?? {});
    return Question(prompt: prompt, type: type, config: config);
  }
}

abstract class QuestionConfig {}

@JsonSerializable(createToJson: false)
class BooleanConfig implements QuestionConfig {
  const BooleanConfig();
}

@JsonSerializable(createToJson: false)
class CounterConfig implements QuestionConfig {
  const CounterConfig();
}

@JsonSerializable(createToJson: false)
class GridConfig implements QuestionConfig {
  final List<String> options;
  final int height;
  final int width;

  const GridConfig({
    required this.options,
    required this.height,
    required this.width,
  });
}

@JsonSerializable(createToJson: false)
class MultipleChoiceConfig implements QuestionConfig {
  final List<String> options;

  const MultipleChoiceConfig({required this.options});
}

@JsonSerializable(createToJson: false)
class NumberInputConfig implements QuestionConfig {
  final int min;
  final int max;

  const NumberInputConfig({required this.min, required this.max});
}

@JsonSerializable(createToJson: false)
class NumberRangeConfig implements QuestionConfig {
  final int min;
  final int max;

  const NumberRangeConfig({required this.min, required this.max});
}

@JsonSerializable(createToJson: false)
class SequenceConfig implements QuestionConfig {
  final List<String> options;

  const SequenceConfig({required this.options});
}

@JsonSerializable(createToJson: false)
class SingleChoiceConfig implements QuestionConfig {
  final List<String> options;

  const SingleChoiceConfig({required this.options});
}

@JsonSerializable(createToJson: false)
class QuestionPage {
  final String key;
  final String title;
  final List<Question> questions;

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
      callback: (questions) => Question.matchQuestions = questions,
      etag: Question._matchQuestionsEtag,
    );

Future<ServerResponse<List<QuestionPage>>> serverGetPitQuestions() =>
    serverRequest(
      endpoint: '/questions/pit',
      method: 'GET',
      decoder: listOf(QuestionPage.fromJson),
      callback: (questions) => Question.pitQuestions = questions,
      etag: Question._pitQuestionsEtag,
    );

Future<ServerResponse<List<Question>>> serverGetDriveTeamQuestions() =>
    serverRequest(
      endpoint: '/questions/drive-team',
      method: 'GET',
      decoder: listOf(Question.fromJson),
      callback: (questions) => Question.driveTeamQuestions = questions,
      etag: Question._driveTeamQuestionsEtag,
    );
