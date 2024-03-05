import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldDecoration extends InputDecoration {
  TextFieldDecoration({
    super.icon,
    super.iconColor,
    super.label,
    super.labelText,
    super.labelStyle,
    super.floatingLabelStyle,
    super.helperText,
    super.helperStyle,
    super.helperMaxLines,
    super.hintText,
    super.hintStyle,
    super.hintTextDirection,
    super.hintMaxLines,
    super.hintFadeDuration,
    super.error,
    super.errorText,
    super.errorStyle,
    super.errorMaxLines,
    super.floatingLabelBehavior,
    super.floatingLabelAlignment,
    super.isCollapsed,
    super.isDense,
    super.prefixIcon,
    super.prefixIconConstraints,
    super.prefix,
    super.prefixText,
    super.prefixStyle,
    super.prefixIconColor,
    super.suffixIcon,
    super.suffix,
    super.suffixText,
    super.suffixStyle,
    super.suffixIconColor,
    super.suffixIconConstraints,
    super.counter,
    super.counterText,
    super.counterStyle,
    super.focusColor,
    super.hoverColor,
    super.errorBorder,
    super.focusedErrorBorder,
    super.disabledBorder,
    super.border,
    super.semanticCounterText,
    super.alignLabelWithHint,
    super.constraints,
    super.contentPadding = const EdgeInsets.all(22),
    super.filled = true,
    super.enabled = true,
    InputBorder? enabledBorder,
    InputBorder? focusedBorder,
    ColorScheme? colorScheme,
    Color? fillColor,
  }) : super(
          enabledBorder: enabledBorder ??
              TextFieldBorder(
                borderColor: colorScheme?.onBackground ?? Colors.transparent,
              ),
          focusedBorder: focusedBorder ??
              TextFieldBorder(
                borderColor: colorScheme?.primary ?? Colors.transparent,
                borderWidth: 2,
              ),
          fillColor: fillColor ?? colorScheme?.background,
        );
}

class TextFieldBorder extends OutlineInputBorder {
  TextFieldBorder({
    super.gapPadding,
    super.borderRadius = const BorderRadius.all(Radius.circular(10)),
    BorderSide? borderSide,
    double borderWidth = 1,
    Color borderColor = Colors.black,
  }) : super(
          borderSide: borderSide ??
              BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
        );
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
