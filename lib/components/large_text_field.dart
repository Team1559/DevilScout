import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LargeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;

  const LargeTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.inputFormatters,
  });

  @override
  State<LargeTextField> createState() => _LargeTextFieldState();
}

class _LargeTextFieldState extends State<LargeTextField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.obscureText,
        inputFormatters: widget.inputFormatters,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.background,
            ),
          ),
          fillColor: Theme.of(context).colorScheme.surface,
          filled: true,
          hintText: widget.hintText,
        ),
      ),
    );
  }
}
