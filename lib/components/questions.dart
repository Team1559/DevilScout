import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

import '/components/horizontal_view.dart';
import '/components/snackbar.dart';
import '/server/questions.dart';
import '/server/server.dart';

class QuestionDisplay extends HorizontalPageView<QuestionPage> {
  final Future<ServerResponse<void>> Function(Map<String, Map<String, dynamic>>)
      submitAction;

  const QuestionDisplay({
    super.key,
    required super.pages,
    required this.submitAction,
  }) : super(lastPageButtonLabel: 'Submit');

  @override
  State<QuestionDisplay> createState() => _QuestionDisplay2State();
}

class _QuestionDisplay2State
    extends HorizontalPageViewState<QuestionPage, QuestionDisplay> {
  final Map<String, Map<String, dynamic>> responses = {};

  @override
  Widget buildPage(QuestionPage page) {
    return _QuestionDisplayPage(
      sectionTitle: page.title,
      questions: page.questions,
      responses: responses.putIfAbsent(page.key, () => {}),
      listener: _listener,
    );
  }

  void _listener() {
    setState(() {});
  }

  @override
  void Function()? lastPageButtonAction() {
    if (!_allQuestionsAnswered()) {
      return null;
    }

    return () => showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text(
              "You won't be able to edit your response after submitting.",
            ),
            actions: [
              TextButton(
                onPressed: Navigator.of(context).pop,
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: _submit,
                child: const Text('Submit'),
              ),
            ],
          ),
        );
  }

  void _submit() {
    widget.submitAction(responses).then((response) {
      if (!context.mounted) return;

      Navigator.pop(context);

      if (!response.success) {
        snackbarError(
          context,
          response.message ?? 'An error occured',
        );
        return;
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success!'),
          content: const Text(
            'Your submission was uploaded to the server, and will be processed within a few minutes.',
          ),
          actions: [
            TextButton(
              child: const Text('Return'),
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
            ),
          ],
        ),
      );
    });
  }

  bool _allQuestionsAnswered() {
    for (QuestionPage page in widget.pages) {
      if (!responses.containsKey(page.key)) {
        return false;
      }

      for (QuestionConfig question in page.questions) {
        if (!responses[page.key]!.containsKey(question.key)) {
          return false;
        }
      }
    }

    return true;
  }
}

class _QuestionDisplayPage extends StatefulWidget {
  final String sectionTitle;
  final List<QuestionConfig> questions;
  final Map<String, dynamic> responses;

  final void Function() listener;

  const _QuestionDisplayPage({
    required this.sectionTitle,
    required this.questions,
    required this.responses,
    required this.listener,
  });

  @override
  State<_QuestionDisplayPage> createState() => _QuestionDisplayPageState();
}

class _QuestionDisplayPageState extends State<_QuestionDisplayPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // required by KeepAlive

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            widget.sectionTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          color: Colors.black,
          height: 2,
        ),
        for (int i = 0; i < widget.questions.length; i++)
          question(context, widget.questions[i]),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget question(BuildContext context, QuestionConfig question) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24, bottom: 8),
          child: Text(
            question.prompt,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
        QuestionWidget.of(
          config: question,
          listener: widget.listener,
          valueSetter: (response) => widget.responses[question.key] = response,
        ),
      ],
    );
  }
}

abstract class QuestionWidget<C extends QuestionConfig> extends StatefulWidget {
  final C config;
  final void Function(dynamic) valueSetter;
  final void Function() listener;

  factory QuestionWidget.of({
    required C config,
    required void Function(dynamic) valueSetter,
    required void Function() listener,
  }) =>
      switch (config) {
        BooleanConfig config => BooleanQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        CounterConfig config => CounterQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        MultipleChoiceConfig config => MultipleChoiceQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        NumberConfig config => NumberQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        RangeConfig config => RangeQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        SequenceConfig config => SequenceQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
        SingleChoiceConfig config => SingleChoiceQuestion(
            config: config,
            valueSetter: valueSetter,
            listener: listener,
          ),
      } as QuestionWidget<C>;

  const QuestionWidget({
    super.key,
    required this.config,
    required this.valueSetter,
    required this.listener,
  });
}

sealed class QuestionWidgetState<T, W extends QuestionWidget> extends State<W> {
  T value;

  QuestionWidgetState({required this.value});

  @override
  void initState() {
    super.initState();
    if (value != null) {
      widget.valueSetter(value);
    }
  }

  void setValue(T newValue) {
    if (value != newValue) {
      value = newValue;
      widget.valueSetter(newValue);
      widget.listener();
    }
  }
}

class BooleanQuestion extends QuestionWidget<BooleanConfig> {
  const BooleanQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<BooleanQuestion> createState() => _BooleanQuestionState();
}

class _BooleanQuestionState
    extends QuestionWidgetState<bool?, BooleanQuestion> {
  _BooleanQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(
          Theme.of(context).textTheme.titleSmall,
        ),
      ),
      emptySelectionAllowed: true,
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: true,
          label: Text('Yes'),
        ),
        ButtonSegment(
          value: false,
          label: Text('No'),
        ),
      ],
      selected: value == null ? {} : {value},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) {
          setValue(set.first);
        }
      },
    );
  }
}

class CounterQuestion extends QuestionWidget<CounterConfig> {
  const CounterQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<CounterQuestion> createState() => _CounterQuestionState();
}

class _CounterQuestionState extends QuestionWidgetState<int, CounterQuestion> {
  _CounterQuestionState() : super(value: 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value == 0 ? null : () => setValue(value - 1),
          icon: const Icon(Icons.remove),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 40),
          child: Text(
            '$value',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        IconButton(
          onPressed: () => setValue(value + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class MultipleChoiceQuestion extends QuestionWidget<MultipleChoiceConfig> {
  const MultipleChoiceQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState
    extends QuestionWidgetState<List<int>, MultipleChoiceQuestion> {
  late final List<bool> active;

  _MultipleChoiceQuestionState() : super(value: []);

  @override
  void initState() {
    super.initState();
    active = List.filled(widget.config.options.length, false);
  }

  void _set(index, selected) {
    if (selected != active[index]) {
      _toggle(index);
    }
  }

  void _toggle(index) {
    setState(() => active[index] = !active[index]);

    if (active[index]) {
      value.add(index);
    } else {
      value.remove(index);
    }
    value.sort();

    widget.listener();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.config.options.length,
        (index) => ListTile(
          dense: true,
          title: Text(
            widget.config.options[index],
            style: Theme.of(context).textTheme.titleSmall,
          ),
          trailing: Checkbox(
            value: active[index],
            onChanged: (b) => _set(index, b),
          ),
          onTap: () => _toggle(index),
        ),
      ),
    );
  }
}

class NumberQuestion extends QuestionWidget<NumberConfig> {
  const NumberQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<NumberQuestion> createState() => _NumberQuestionState();
}

class _NumberQuestionState extends QuestionWidgetState<int?, NumberQuestion> {
  final TextEditingController controller = TextEditingController();

  _NumberQuestionState() : super(value: null);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => setValue(widget.config.defaultValue));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_left),
          onPressed: value == null || value! <= widget.config.min
              ? null
              : () => setValue(value! - 1),
        ),
        NumberPicker(
          selectedTextStyle: Theme.of(context).textTheme.titleMedium,
          axis: Axis.horizontal,
          minValue: widget.config.min,
          maxValue: widget.config.max,
          value: value ?? widget.config.defaultValue,
          itemCount: 5,
          itemWidth: 40,
          onChanged: setValue,
        ),
        IconButton(
          icon: const Icon(Icons.keyboard_arrow_right),
          onPressed: value == null || value! >= widget.config.max
              ? null
              : () => setValue(value! + 1),
        ),
      ],
    );
  }
}

class RangeQuestion extends QuestionWidget<RangeConfig> {
  const RangeQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<RangeQuestion> createState() => _RangeQuestionState();
}

class _RangeQuestionState extends QuestionWidgetState<int?, RangeQuestion> {
  _RangeQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
      style: ButtonStyle(
        textStyle: MaterialStatePropertyAll(
          Theme.of(context).textTheme.titleSmall,
        ),
      ),
      emptySelectionAllowed: true,
      selected: value == null ? {} : {value},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) {
          setValue(set.first);
        }
      },
      showSelectedIcon: false,
      segments: [
        for (int value = widget.config.min;
            value <= widget.config.max;
            value += widget.config.increment)
          ButtonSegment(
            label: Text('$value'),
            value: value,
          )
      ],
    );
  }
}

class SequenceQuestion extends QuestionWidget<SequenceConfig> {
  const SequenceQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<SequenceQuestion> createState() => _SequenceQuestionState();
}

class _SequenceQuestionState
    extends QuestionWidgetState<List<int?>, SequenceQuestion> {
  _SequenceQuestionState() : super(value: []);

  @override
  Widget build(BuildContext context) {
    List<DropdownMenuItem<int>> entries = List.generate(
      widget.config.options.length,
      (index) => DropdownMenuItem(
        value: index,
        child: Text(widget.config.options[index]),
      ),
    );

    return Column(
      children: [
        Column(
          children: List.generate(
            value.length + 1,
            (index) => DropdownButton(
              hint: const Text('End of sequence'),
              items: entries,
              value: index == value.length ? null : value[index],
              onChanged: (v) {
                setState(() {
                  value.length = index + 1;
                  value[index] = v;
                });
              },
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            value.length = 0;
          }),
          child: const Text('Reset'),
        )
      ],
    );
  }
}

class SingleChoiceQuestion extends QuestionWidget<SingleChoiceConfig> {
  const SingleChoiceQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.listener,
  });

  @override
  State<SingleChoiceQuestion> createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState
    extends QuestionWidgetState<int?, SingleChoiceQuestion> {
  _SingleChoiceQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Column(
          children: widget.config.options.asMap().entries.map((entry) {
            int idx = entry.key;
            String val = entry.value;
            return Column(
              children: [
                if (idx != 0)
                  const Divider(
                    height: 2.0,
                    color: Colors.black,
                    thickness: 2,
                  ),
                InkWell(
                  onTap: () => setValue(idx),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    color: value == idx
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    child: ListTile(
                      dense: true,
                      title: Text(
                        val,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
