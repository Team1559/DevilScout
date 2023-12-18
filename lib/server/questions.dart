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
      callback: (questions) => MatchQuestions.current = questions,
      etag: MatchQuestions._etag,
    );

Future<ServerResponse<PitQuestions>> serverGetPitQuestions() => serverRequest(
      endpoint: '/questions/pit',
      method: 'GET',
      decoder: PitQuestions.fromJson,
      callback: (questions) => PitQuestions.current = questions,
      etag: PitQuestions._etag,
    );

Future<ServerResponse<DriveTeamQuestions>> serverGetDriveTeamQuestions() =>
    serverRequest(
      endpoint: '/questions/drive-team',
      method: 'GET',
      decoder: DriveTeamQuestions.fromJson,
      callback: (questions) => DriveTeamQuestions.current = questions,
      etag: DriveTeamQuestions._etag,
    );
