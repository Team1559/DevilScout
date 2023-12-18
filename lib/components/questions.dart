import 'package:flutter/material.dart';

import '/server/questions.dart';

class QuestionDisplay extends StatefulWidget {
  final List<(String, List<Question>?)> questions;
  final void Function(Map<String, List<dynamic>>) submitAction;

  const QuestionDisplay({
    super.key,
    required this.questions,
    required this.submitAction,
  });

  @override
  State<QuestionDisplay> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay> {
  late final List<List<dynamic>> _values;

  @override
  void initState() {
    _values = List.generate(
      widget.questions.length,
      (index) => List.empty(growable: true),
    );
    super.initState();
  }

  int _currentPage = 0;

  void _nextButton() {
    if (_currentPage < widget.questions.length - 1) {
      setState(() => _currentPage++);
    }
  }

  void _backButton() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Question> questions = widget.questions[_currentPage].$2 ?? [];
    List<dynamic> responses = _values[_currentPage];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton(
                onPressed: _backButton,
                child: const Text('Back'),
              ),
              const Spacer(),
              Text(
                widget.questions[_currentPage].$1,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              FilledButton(
                onPressed: _nextButton,
                child: Text(
                  _currentPage == widget.questions.length - 1
                      ? 'Submit'
                      : 'Next',
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: questions.length,
            itemBuilder: (context, index) => Center(
              child: QuestionWidget.of(
                question: questions[index],
                responseSetter: (response) {
                  if (responses.length <= index) {
                    responses.length = index + 1;
                  }
                  responses[index] = response;
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

abstract class QuestionWidget extends StatefulWidget {
  final Question question;
  final void Function(dynamic) valueSetter;

  factory QuestionWidget.of({
    required Question question,
    required void Function(dynamic) responseSetter,
  }) =>
      switch (question.type) {
        QuestionType.boolean =>
          BooleanQuestion(question: question, valueSetter: responseSetter),
        QuestionType.counter =>
          CounterQuestion(question: question, valueSetter: responseSetter),
        QuestionType.grid =>
          GridQuestion(question: question, valueSetter: responseSetter),
        QuestionType.multiple => MultipleChoiceQuestion(
            question: question, valueSetter: responseSetter),
        QuestionType.number =>
          NumberInputQuestion(question: question, valueSetter: responseSetter),
        QuestionType.range =>
          NumberRangeQuestion(question: question, valueSetter: responseSetter),
        QuestionType.sequence =>
          SequenceQuestion(question: question, valueSetter: responseSetter),
        QuestionType.single =>
          SingleChoiceQuestion(question: question, valueSetter: responseSetter),
      };

  const QuestionWidget({
    super.key,
    required this.question,
    required this.valueSetter,
  });
}

abstract class QuestionWidgetState<T, W extends QuestionWidget>
    extends State<W> {
  T? response;
  void setResponse(T? value) {
    setState(() {
      response = value;
    });
    widget.valueSetter.call(value);
  }
}

class BooleanQuestion extends QuestionWidget {
  const BooleanQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<BooleanQuestion> createState() => _BooleanQuestionState();
}

class _BooleanQuestionState extends QuestionWidgetState<bool, BooleanQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class CounterQuestion extends QuestionWidget {
  const CounterQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<CounterQuestion> createState() => _CounterQuestionState();
}

class _CounterQuestionState extends QuestionWidgetState<int, CounterQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class GridQuestion extends QuestionWidget {
  const GridQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<GridQuestion> createState() => _GridQuestionState();
}

class _GridQuestionState
    extends QuestionWidgetState<List<List<int>>, GridQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class MultipleChoiceQuestion extends QuestionWidget {
  const MultipleChoiceQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState
    extends QuestionWidgetState<List<int>, MultipleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class NumberInputQuestion extends QuestionWidget {
  const NumberInputQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<NumberInputQuestion> createState() => _NumberInputQuestionState();
}

class _NumberInputQuestionState
    extends QuestionWidgetState<int, NumberInputQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class NumberRangeQuestion extends QuestionWidget {
  const NumberRangeQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<NumberRangeQuestion> createState() => _NumberRangeQuestionState();
}

class _NumberRangeQuestionState
    extends QuestionWidgetState<int, NumberRangeQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class SequenceQuestion extends QuestionWidget {
  const SequenceQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<SequenceQuestion> createState() => _SequenceQuestionState();
}

class _SequenceQuestionState
    extends QuestionWidgetState<List<int>, SequenceQuestion> {
  @override
  Widget build(BuildContext context) {
    return Text(widget.question.prompt);
  }
}

class SingleChoiceQuestion extends QuestionWidget {
  const SingleChoiceQuestion({
    super.key,
    required super.question,
    required super.valueSetter,
  });

  @override
  State<SingleChoiceQuestion> createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState
    extends QuestionWidgetState<int, SingleChoiceQuestion> {
  @override
  Widget build(BuildContext context) {
    widget.valueSetter.call(4);
    return Text(widget.question.prompt);
  }
}
