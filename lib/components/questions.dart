import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/server/questions.dart';
import 'large_text_field.dart';

class QuestionDisplay extends StatefulWidget {
  final List<QuestionPage> pages;
  final void Function(Map<String, Map<String, dynamic>>) submitAction;

  const QuestionDisplay({
    super.key,
    required this.pages,
    required this.submitAction,
  });

  @override
  State<QuestionDisplay> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends State<QuestionDisplay> {
  final PageController controller = PageController();
  late final Map<String, Map<String, dynamic>> responses;

  @override
  void initState() {
    super.initState();
    responses = {};
  }

  void nextPage() {
    controller.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void previousPage() {
    if (controller.page! > 0) {
      controller.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView(
          controller: controller,
          children: List.generate(widget.pages.length, (index) {
            String name = widget.pages[index].title;
            List<QuestionConfig>? questions = widget.pages[index].questions;

            return _QuestionDisplayPage(
              name: name,
              questions: questions,
              responses:
                  responses.putIfAbsent(widget.pages[index].key, () => {}),
              previousPage: index == 0 ? null : previousPage,
              nextPage: index == widget.pages.length - 1 ? null : nextPage,
              setState: setState,
            );
          }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: FilledButton(
              onPressed: _allQuestionsAnswered()
                  ? () => widget.submitAction.call(responses)
                  : null,
              child: const Text('Submit'),
            ),
          ),
        ),
      ],
    );
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
  final String name;
  final List<QuestionConfig> questions;
  final Map<String, dynamic> responses;

  final void Function()? previousPage;
  final void Function()? nextPage;
  final void Function(void Function()) setState;

  const _QuestionDisplayPage({
    required this.name,
    required this.questions,
    required this.responses,
    required this.previousPage,
    required this.nextPage,
    required this.setState,
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
    super.build(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: widget.previousPage,
                icon: const Icon(Icons.navigate_before),
              ),
              const Spacer(),
              Text(
                widget.name,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: widget.nextPage,
                icon: const Icon(Icons.navigate_next),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ListView.builder(
              itemCount: widget.questions.length,
              itemBuilder: question,
            ),
          ),
        ),
      ],
    );
  }

  Widget question(BuildContext context, int index) {
    QuestionConfig question = widget.questions[index];
    return Center(
      child: Column(
        children: [
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          QuestionWidget.of(
            config: question,
            setState: (void Function() callback) {
              setState(callback);
              widget.setState.call(() {});
            },
            valueSetter: (response) =>
                widget.responses[question.key] = response,
          ),
        ],
      ),
    );
  }
}

abstract class QuestionWidget<C extends QuestionConfig> extends StatefulWidget {
  final C config;
  final void Function(dynamic) valueSetter;
  final void Function(void Function()) setState;

  static QuestionWidget<C> of<C extends QuestionConfig>({
    required C config,
    required void Function(dynamic) valueSetter,
    required void Function(void Function()) setState,
  }) =>
      switch (config) {
        BooleanConfig config => BooleanQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        CounterConfig config => CounterQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        MultipleChoiceConfig config => MultipleChoiceQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        NumberConfig config => NumberQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        RangeConfig config => RangeQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        SequenceConfig config => SequenceQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        SingleChoiceConfig config => SingleChoiceQuestion(
            config: config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        _ => throw Exception()
      } as QuestionWidget<C>;

  const QuestionWidget({
    super.key,
    required this.config,
    required this.valueSetter,
    required this.setState,
  });
}

abstract class QuestionWidgetState<T, W extends QuestionWidget>
    extends State<W> {
  T value;

  QuestionWidgetState({required this.value});

  @override
  void initState() {
    super.initState();
    if (value != null) {
      widget.valueSetter.call(value);
    }
  }

  void setValue(T newValue) {
    if (value != newValue) {
      widget.setState.call(() {
        value = newValue;
        widget.valueSetter.call(newValue);
      });
    }
  }
}

class BooleanQuestion extends QuestionWidget<BooleanConfig> {
  const BooleanQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<BooleanQuestion> createState() => _BooleanQuestionState();
}

class _BooleanQuestionState extends QuestionWidgetState<int?, BooleanQuestion> {
  _BooleanQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
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
      selected: value == null ? {} : {value == 1},
      onSelectionChanged: (set) {
        if (set.isNotEmpty) {
          setValue(set.first ? 1 : 0);
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
    required super.setState,
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
    required super.setState,
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
      setState(() {
        active[index] = selected;
      });

      widget.setState.call(() {
        if (selected) {
          value.add(index);
        } else {
          value.remove(index);
        }
        value.sort();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.config.options.length,
        (index) => CheckboxListTile(
          title: Text(widget.config.options[index]),
          value: active[index],
          onChanged: (value) => _set(index, value),
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
    required super.setState,
  });

  @override
  State<NumberQuestion> createState() => _NumberQuestionState();
}

class _NumberQuestionState extends QuestionWidgetState<int?, NumberQuestion> {
  final TextEditingController controller = TextEditingController();

  _NumberQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return LargeTextField(
      hintText: '${widget.config.min}-${widget.config.max}',
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberTextInputFormatter(min: widget.config.min, max: widget.config.max)
      ],
      keyboardType: TextInputType.number,
      onChanged: (text) => setValue(int.tryParse(text)),
    );
  }
}

class NumberTextInputFormatter extends TextInputFormatter {
  final int min;
  final int max;

  const NumberTextInputFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    int num = int.parse(newValue.text);
    if (num < min || num > max) {
      return oldValue;
    } else if (newValue.text.startsWith('0') && newValue.text.length > 1) {
      return const TextEditingValue(text: '0');
    } else {
      return newValue;
    }
  }
}

class RangeQuestion extends QuestionWidget<RangeConfig> {
  const RangeQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<RangeQuestion> createState() => _RangeQuestionState();
}

class _RangeQuestionState extends QuestionWidgetState<int?, RangeQuestion> {
  _RangeQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return SegmentedButton(
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
    required super.setState,
  });

  @override
  State<SequenceQuestion> createState() => _SequenceQuestionState();
}

class _SequenceQuestionState
    extends QuestionWidgetState<List<int?>, SequenceQuestion> {
  _SequenceQuestionState() : super(value: [null]);

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
            value.length,
            (index) => DropdownButton(
              hint: const Text('End of sequence'),
              items: entries,
              value: value[index],
              onChanged: (v) {
                setState(() {
                  value.length = index + 2;
                  value[index] = v;
                  value[index + 1] = null;
                });
              },
            ),
          ),
        ),
        TextButton(
          onPressed: () => setState(() {
            value.length = 1;
            value[0] = null;
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
    required super.setState,
  });

  @override
  State<SingleChoiceQuestion> createState() => _SingleChoiceQuestionState();
}

class _SingleChoiceQuestionState
    extends QuestionWidgetState<int?, SingleChoiceQuestion> {
  _SingleChoiceQuestionState() : super(value: null);

  @override
  Widget build(BuildContext context) {
    return DropdownButton(
      hint: const Text('Select one'),
      items: List.generate(
        widget.config.options.length,
        (index) => DropdownMenuItem(
          value: index,
          child: Text(widget.config.options[index]),
        ),
      ),
      value: value,
      onChanged: setValue,
    );
  }
}
