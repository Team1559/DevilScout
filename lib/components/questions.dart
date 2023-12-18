import 'package:flutter/material.dart';

import '/server/questions.dart';

abstract class QuestionWidget extends StatefulWidget {
  final Question question;

  factory QuestionWidget.of(Question question) => switch (question.type) {
        QuestionType.boolean => BooleanQuestion(question: question),
        QuestionType.counter => CounterQuestion(question: question),
        QuestionType.grid => GridQuestion(question: question),
        QuestionType.multiple => MultipleChoiceQuestion(question: question),
        QuestionType.number => NumberInputQuestion(question: question),
        QuestionType.range => NumberRangeQuestion(question: question),
        QuestionType.sequence => SequenceQuestion(question: question),
        QuestionType.single => SingleChoiceQuestion(question: question),
      };

  const QuestionWidget({super.key, required this.question});
}

class BooleanQuestion extends QuestionWidget {
  const BooleanQuestion({super.key, required super.question});

  @override
  State<BooleanQuestion> createState() => _BooleanQuestionState();
}

class _BooleanQuestionState extends State<BooleanQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class CounterQuestion extends QuestionWidget {
  const CounterQuestion({super.key, required super.question});

  @override
  State<CounterQuestion> createState() => _CounterQuestionState();
}

class _CounterQuestionState extends State<CounterQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class GridQuestion extends QuestionWidget {
  const GridQuestion({super.key, required super.question});

  @override
  State<GridQuestion> createState() => _GridQuestionState();
}

class _GridQuestionState extends State<GridQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class MultipleChoiceQuestion extends QuestionWidget {
  const MultipleChoiceQuestion({super.key, required super.question});

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends State<MultipleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class NumberInputQuestion extends QuestionWidget {
  const NumberInputQuestion({super.key, required super.question});

  @override
  State<NumberInputQuestion> createState() => _NumberInputQuestionState();
}

class _NumberInputQuestionState extends State<NumberInputQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class NumberRangeQuestion extends QuestionWidget {
  const NumberRangeQuestion({super.key, required super.question});

  @override
  State<NumberRangeQuestion> createState() => _NumberRangeQuestionState();
}

class _NumberRangeQuestionState extends State<NumberRangeQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class SequenceQuestion extends QuestionWidget {
  const SequenceQuestion({super.key, required super.question});

  @override
  State<SequenceQuestion> createState() => _SequenceQuestionState();
}

class _SequenceQuestionState extends State<SequenceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class SingleChoiceQuestion extends QuestionWidget {
  const SingleChoiceQuestion({super.key, required super.question});

  @override
  State<SingleChoiceQuestion> createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState extends State<SingleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}
