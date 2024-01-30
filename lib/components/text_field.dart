import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LargeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final bool autocorrect;
  final bool autofocus;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;

  const LargeTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.autocorrect = false,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction,
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        style: Theme.of(context).textTheme.labelLarge,
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        autocorrect: autocorrect,
        enableInteractiveSelection: !obscureText,
        autofocus: autofocus,
        focusNode: focusNode,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.onBackground,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          fillColor: Theme.of(context).colorScheme.background,
          filled: true,
          contentPadding: const EdgeInsets.all(22),
          hintText: hintText,
        ),
      ),
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
