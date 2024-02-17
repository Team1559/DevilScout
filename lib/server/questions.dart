import 'package:json_annotation/json_annotation.dart';

import '/server/server.dart';
import '/server/teams.dart';

part 'questions.g.dart';

/// The types of questions that can be displayed to the user
@JsonEnum(fieldRename: FieldRename.screamingSnake, alwaysCreate: true)
enum QuestionType {
  boolean(_$BooleanConfigFromJson),
  counter(_$CounterConfigFromJson),
  multiple(_$MultipleChoiceConfigFromJson),
  number(_$NumberConfigFromJson),
  range(_$RangeConfigFromJson),
  sequence(_$SequenceConfigFromJson),
  single(_$SingleChoiceConfigFromJson);

  final QuestionConfig Function(Map<String, dynamic>) _parser;

  const QuestionType(this._parser);
}

/// The configuration for a displayed question. A question widget will receive a
/// subtype of this class that defines its prompt, key, and other type-specific
/// information.
sealed class QuestionConfig {
  /// The cached list of match questions from the server, after calling
  /// [serverGetMatchQuestions]
  static List<QuestionPage> matchQuestions = List.empty();

  /// The cached list of pit questions from the server, after calling
  /// [serverGetPitQuestions]
  static List<QuestionPage> pitQuestions = List.empty();

  /// The cached list of drive team questions from the server, after calling
  /// [serverGetDriveTeamQuestions]
  static List<QuestionConfig> driveTeamQuestions = List.empty();

  static final Etag _matchQuestionsEtag = Etag();
  static final Etag _pitQuestionsEtag = Etag();
  static final Etag _driveTeamQuestionsEtag = Etag();

  /// Clear the cached match, pit, and drive team questions from this device
  static void clear() {
    matchQuestions = List.empty();
    pitQuestions = List.empty();
    driveTeamQuestions = List.empty();

    _matchQuestionsEtag.clear();
    _pitQuestionsEtag.clear();
    _driveTeamQuestionsEtag.clear();
  }

  /// The prompt/question to display to the user
  final String prompt;

  /// The map key under which this question's response should be entered
  final String key;

  const QuestionConfig({
    required this.prompt,
    required this.key,
  });

  /// Decode a registered config type from JSON, depending on its 'type' field
  factory QuestionConfig.fromJson(Map<String, dynamic> json) =>
      $enumDecode(_$QuestionTypeEnumMap, json['type'])._parser(json);
}

/// Configuration for a boolean question. Responses are either `true` or `false`.
@JsonSerializable(createToJson: false)
class BooleanConfig extends QuestionConfig {
  const BooleanConfig({
    required super.prompt,
    required super.key,
  });
}

/// Configuration for a counter question. Responses are a non-negative integer.
@JsonSerializable(createToJson: false)
class CounterConfig extends QuestionConfig {
  const CounterConfig({
    required super.prompt,
    required super.key,
  });
}

/// Configuration for a multiple-choice question (not to be confused with
/// [SingleChoiceConfig]). Users select zero or more options to send. Responses
/// are a list of the selected options' indices.
@JsonSerializable(createToJson: false)
class MultipleChoiceConfig extends QuestionConfig {
  /// The list of options to display to the user, in order
  final List<String> options;

  const MultipleChoiceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

/// Configuration for a number input question. Responses are a single integer
/// (from a text field).
@JsonSerializable(createToJson: false)
class NumberConfig extends QuestionConfig {
  /// The minimum permitted response (inclusive)
  final int min;

  /// The maximum permitted response (inclusive)
  final int max;

  /// The value to show by default
  @JsonKey(name: 'default')
  final int defaultValue;

  const NumberConfig({
    required super.prompt,
    required super.key,
    required this.min,
    required this.max,
    required this.defaultValue,
  });
}

/// Configuration for a range input question. Responses are a single integer
/// (from a list of options).
@JsonSerializable(createToJson: false)
class RangeConfig extends QuestionConfig {
  /// The minimum permitted response (inclusive)
  final int min;

  /// The maximum permitted response (inclusive)
  final int max;

  /// The amount by which to increment subsequent options. Defaults to 1 if not
  /// present.
  final int increment;

  const RangeConfig({
    required super.prompt,
    required super.key,
    required this.min,
    required this.max,
    this.increment = 1,
  });
}

/// Configuration for a sequence question. Users enter a list of these options
/// in any order. Duplicates or empty lists are permitted. Responses are ordered
/// lists of the indices of selected options.
@JsonSerializable(createToJson: false)
class SequenceConfig extends QuestionConfig {
  /// The list of options to display to the user, in order
  final List<String> options;

  const SequenceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

/// Configuration for a single-choice question (not to be confused with
/// [MultipleChoiceConfig]). Users must select exactly one of the options
/// presented. Responses are the index of the selected response.
@JsonSerializable(createToJson: false)
class SingleChoiceConfig extends QuestionConfig {
  /// The list of options to display to the user, in order
  final List<String> options;

  const SingleChoiceConfig({
    required super.prompt,
    required super.key,
    required this.options,
  });
}

/// Configuration for a page of questions.
@JsonSerializable(createToJson: false)
class QuestionPage {
  /// The key under which to file this page's responses
  final String key;

  /// The title to display on this page
  final String title;

  /// Configurations for the questions to display on this page
  final List<QuestionConfig> questions;

  const QuestionPage({
    required this.key,
    required this.title,
    required this.questions,
  });

  /// Deserialize a [QuestionPage] from JSON
  factory QuestionPage.fromJson(Map<String, dynamic> json) =>
      _$QuestionPageFromJson(json);

  /// Override [key] and [title] with a new value (for drive team questions)
  QuestionPage driveTeam(String key, String title) =>
      QuestionPage(key: key, title: title, questions: questions);
}

/// Get the list of match questions from the server. Upon success, the result
/// will be cached in [QuestionConfig.matchQuestions].
Future<ServerResponse<List<QuestionPage>>> serverGetMatchQuestions() =>
    serverRequest(
      path: 'questions/${Team.current!.eventKey}/match',
      method: 'GET',
      decoder: listOf(QuestionPage.fromJson),
      callback: (questions) => QuestionConfig.matchQuestions = questions,
      etag: QuestionConfig._matchQuestionsEtag,
    );

/// Get the list of pit questions from the server. Upon success, the result
/// will be cached in [QuestionConfig.pitQuestions].
Future<ServerResponse<List<QuestionPage>>> serverGetPitQuestions() =>
    serverRequest(
      path: 'questions/${Team.current!.eventKey}/pit',
      method: 'GET',
      decoder: listOf(QuestionPage.fromJson),
      callback: (questions) => QuestionConfig.pitQuestions = questions,
      etag: QuestionConfig._pitQuestionsEtag,
    );

/// Get the list of drive team questions from the server. Upon success, the
/// result will be cached in [QuestionConfig.driveTeamQuestions].
Future<ServerResponse<List<QuestionConfig>>> serverGetDriveTeamQuestions() =>
    serverRequest(
      path: 'questions/${Team.current!.eventKey}/drive-team',
      method: 'GET',
      decoder: listOf(QuestionConfig.fromJson),
      callback: (questions) => QuestionConfig.driveTeamQuestions = questions,
      etag: QuestionConfig._driveTeamQuestionsEtag,
    );
