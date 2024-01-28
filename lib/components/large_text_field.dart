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
      padding: const EdgeInsets.only(bottom: 15.0),
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
                width: 2.0,
              )),
          fillColor: Theme.of(context).colorScheme.background,
          filled: true,
          contentPadding: const EdgeInsets.all(22.0),
          hintText: hintText,
        ),
      ),
    );
  }
}
