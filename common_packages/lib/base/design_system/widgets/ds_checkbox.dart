import 'package:flutter/material.dart';

/// A checkbox with an optional label and description.
///
/// Usage:
/// ```dart
/// DSCheckbox(
///   value: _agreed,
///   label: 'I agree to Terms',
///   onChanged: (v) => setState(() => _agreed = v!),
/// )
///
/// DSCheckbox(
///   value: _notify,
///   label: 'Enable notifications',
///   description: 'Receive push notifications for new messages',
///   onChanged: (v) => setState(() => _notify = v!),
/// )
/// ```
class DSCheckbox extends StatelessWidget {
  const DSCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.description,
    this.enabled = true,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? description;
  final bool enabled;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Checkbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        tristate: tristate,
      );
    }

    return InkWell(
      onTap: enabled && onChanged != null
          ? () => onChanged!(tristate ? _nextTristate() : !(value ?? false))
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: description != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: value,
              onChanged: enabled ? onChanged : null,
              tristate: tristate,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: enabled
                              ? null
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                        ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      description!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withOpacity(0.6),
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool? _nextTristate() {
    if (value == null) return true;
    if (value!) return false;
    return null;
  }
}
