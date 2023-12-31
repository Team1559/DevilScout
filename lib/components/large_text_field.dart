import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LargeTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final bool obscureText;
  final bool autocorrect;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;

  const LargeTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.obscureText = false,
    this.autocorrect = false,
    this.textInputAction,
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: TextField(
        onChanged: onChanged,
        controller: controller,
        obscureText: obscureText,
        autocorrect: autocorrect,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
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
