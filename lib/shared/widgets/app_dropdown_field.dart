import 'package:flutter/material.dart';

import '../../core/theme/app_dimensions.dart';

/// A dropdown form field with its label above it, matching [AppTextField].
class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    super.key,
    required this.label,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.value,
    this.hint,
    this.validator,
    this.enabled = true,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?> onChanged;
  final T? value;
  final String? hint;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<T>(
          initialValue: value,
          isExpanded: true,
          validator: validator,
          decoration: InputDecoration(hintText: hint),
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(itemLabel(item))),
          ],
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );
  }
}
