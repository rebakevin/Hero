import 'package:flutter/material.dart';

import 'app_text_field.dart';

/// A password [AppTextField] with a show/hide toggle.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    this.label = 'Password',
    this.hint,
    this.validator,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final ValueChanged<String>? onSubmitted;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: widget.label,
      hint: widget.hint,
      controller: widget.controller,
      validator: widget.validator,
      enabled: widget.enabled,
      obscureText: !_visible,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      onSubmitted: widget.onSubmitted,
      suffix: IconButton(
        tooltip: _visible ? 'Hide password' : 'Show password',
        icon: Icon(
          _visible ? Icons.visibility_off_rounded : Icons.visibility_rounded,
        ),
        onPressed: () => setState(() => _visible = !_visible),
      ),
    );
  }
}
