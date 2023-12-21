import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/server/questions.dart';
import 'large_text_field.dart';

class QuestionDisplay extends StatefulWidget {
  final List<(String, String, List<Question>?)> questions;
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
  final PageController controller = PageController();
  late final List<List<dynamic>> values;

  @override
  void initState() {
    super.initState();
    values = List.generate(
      widget.questions.length,
      (index) => List.empty(growable: true),
    );
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
          children: List.generate(widget.questions.length, (index) {
            String name = widget.questions[index].$1;
            List<Question>? questions = widget.questions[index].$3 ?? [];
            if (values[index].length < questions.length) {
              values[index].length = questions.length;
            }

            return QuestionPage(
              name: name,
              questions: questions,
              values: values[index],
              previousPage: index == 0 ? null : previousPage,
              nextPage: index == widget.questions.length - 1 ? null : nextPage,
              setState: setState,
            );
          }),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
            child: FilledButton(
              onPressed: values.where((e) => e.contains(null)).isNotEmpty
                  ? null
                  : () {
                      Map<String, List<dynamic>> data = Map.fromIterables(
                          widget.questions.map((e) => e.$2), values);
                      widget.submitAction.call(data);
                    },
              child: const Text('Submit'),
            ),
          ),
        ),
      ],
    );
  }
}

class QuestionPage extends StatefulWidget {
  final String name;
  final List<Question> questions;
  final List<dynamic> values;

  final void Function()? previousPage;
  final void Function()? nextPage;
  final void Function(void Function()) setState;

  const QuestionPage({
    super.key,
    required this.name,
    required this.questions,
    required this.values,
    required this.previousPage,
    required this.nextPage,
    required this.setState,
  });

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
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
    Question question = widget.questions[index];
    return Center(
      child: Column(
        children: [
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          QuestionWidget.of(
            question: question,
            setState: (void Function() callback) {
              setState(callback);
              widget.setState.call(() {});
            },
            valueSetter: (response) {
              if (widget.values.length <= index) {
                widget.values.length = index + 1;
              }
              if (widget.values[index] != response) {
                widget.values[index] = response;
              }
            },
          ),
        ],
      ),
    );
  }
}

abstract class QuestionWidget extends StatefulWidget {
  final QuestionConfig config;
  final void Function(dynamic) valueSetter;
  final void Function(void Function()) setState;

  factory QuestionWidget.of({
    required Question question,
    required void Function(dynamic) valueSetter,
    required void Function(void Function()) setState,
  }) =>
      switch (question.type) {
        QuestionType.boolean => BooleanQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.counter => CounterQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.grid => GridQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.multiple => MultipleChoiceQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.number => NumberInputQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.range => NumberRangeQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.sequence => SequenceQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
        QuestionType.single => SingleChoiceQuestion(
            config: question.config,
            valueSetter: valueSetter,
            setState: setState,
          ),
      };

  const QuestionWidget({
    super.key,
    required this.config,
    required this.valueSetter,
    required this.setState,
  });
}

abstract class QuestionWidgetState<T, W extends QuestionWidget,
    C extends QuestionConfig> extends State<W> {
  late final C config;

  T? value;

  QuestionWidgetState({this.value});

  @override
  void initState() {
    super.initState();
    config = widget.config as C;
    if (value != null) {
      widget.valueSetter.call(value);
    }
  }

  void setValue(T? newValue) {
    if (value != newValue) {
      widget.setState.call(() {
        value = newValue;
        widget.valueSetter.call(newValue);
      });
    }
  }
}

class BooleanQuestion extends QuestionWidget {
  const BooleanQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<BooleanQuestion> createState() => _BooleanQuestionState();
}

class _BooleanQuestionState
    extends QuestionWidgetState<int, BooleanQuestion, BooleanConfig> {
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

class CounterQuestion extends QuestionWidget {
  const CounterQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<CounterQuestion> createState() => _CounterQuestionState();
}

class _CounterQuestionState
    extends QuestionWidgetState<int, CounterQuestion, CounterConfig> {
  _CounterQuestionState() : super(value: 0);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: value == 0 ? null : () => setValue(value! - 1),
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
          onPressed: () => setValue(value! + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

class GridQuestion extends QuestionWidget {
  const GridQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<GridQuestion> createState() => _GridQuestionState();
}

class _GridQuestionState
    extends QuestionWidgetState<List<List<int>>, GridQuestion, GridConfig> {
  _GridQuestionState() : super(value: List.empty());

  @override
  Widget build(BuildContext context) {
    return const Text("This is a GRID question. It doesn't work yet.");
  }
}

class MultipleChoiceQuestion extends QuestionWidget {
  const MultipleChoiceQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<MultipleChoiceQuestion> createState() => _MultipleChoiceQuestionState();
}

class _MultipleChoiceQuestionState extends QuestionWidgetState<List<int>,
    MultipleChoiceQuestion, MultipleChoiceConfig> {
  late final List<bool> active;

  _MultipleChoiceQuestionState() : super(value: []);

  @override
  void initState() {
    super.initState();
    active = List.filled(config.options.length, false);
  }

  void _set(index, selected) {
    if (selected != active[index]) {
      setState(() {
        active[index] = selected;
      });

      widget.setState.call(() {
        if (selected) {
          value!.add(index);
        } else {
          value!.remove(index);
        }
        value!.sort();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        config.options.length,
        (index) => CheckboxListTile(
          title: Text(config.options[index]),
          value: active[index],
          onChanged: (value) => _set(index, value),
        ),
      ),
    );
  }
}

class NumberInputQuestion extends QuestionWidget {
  const NumberInputQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<NumberInputQuestion> createState() => _NumberInputQuestionState();
}

class _NumberInputQuestionState
    extends QuestionWidgetState<int, NumberInputQuestion, NumberInputConfig> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LargeTextField(
      hintText: '${config.min}-${config.max}',
      controller: controller,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        NumberTextInputFormatter(min: config.min, max: config.max)
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

class NumberRangeQuestion extends QuestionWidget {
  const NumberRangeQuestion({
    super.key,
    required super.config,
    required super.valueSetter,
    required super.setState,
  });

  @override
  State<NumberRangeQuestion> createState() => _NumberRangeQuestionState();
}

class _NumberRangeQuestionState
    extends QuestionWidgetState<int, NumberRangeQuestion, NumberRangeConfig> {
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
      segments: List.generate(
        config.max - config.min + 1,
        (index) => ButtonSegment(
          label: Text('${config.min + index}'),
          value: config.min + index,
        ),
      ),
    );
  }
}

class SequenceQuestion extends QuestionWidget {
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
    extends QuestionWidgetState<List<int?>, SequenceQuestion, SequenceConfig> {
  @override
  Widget build(BuildContext context) {
    List<DropdownMenuEntry> entries = List.generate(
      config.options.length,
      (index) => DropdownMenuEntry(
        value: index,
        label: config.options[index],
      ),
    );
    entries.add(const DropdownMenuEntry(value: -1, label: 'End'));

    return Column(
      children: List.generate(
        value?.length ?? 1,
        (index) => DropdownMenu(
          hintText: 'Select one',
          dropdownMenuEntries: entries,
          onSelected: (v) {
            setState(() {
              if (value == null) {
                setValue(List.filled(1, null, growable: true));
              }

              if (v == -1) {
                value!.length = index + 1;
              } else if (value!.length == index + 1) {
                value!.length = index + 2;
              }

              value![index] = v;
            });
          },
        ),
      ),
    );
  }
}

class SingleChoiceQuestion extends QuestionWidget {
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
    extends QuestionWidgetState<int, SingleChoiceQuestion, SingleChoiceConfig> {
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<int>(
      hintText: 'Select one',
      dropdownMenuEntries: List.generate(
        config.options.length,
        (index) => DropdownMenuEntry(
          value: index,
          label: config.options[index],
        ),
      ),
      onSelected: setValue,
    );
  }
}
