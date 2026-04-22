import 'package:flutter/material.dart';

/// A radio button group with labels.
///
/// Usage:
/// ```dart
/// DSRadioGroup<String>(
///   value: _selected,
///   items: [
///     DSRadioItem(value: 'male', label: 'Male'),
///     DSRadioItem(value: 'female', label: 'Female'),
///     DSRadioItem(value: 'other', label: 'Other'),
///   ],
///   onChanged: (v) => setState(() => _selected = v),
/// )
/// ```
class DSRadioItem<T> {
  const DSRadioItem({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

class DSRadioGroup<T> extends StatelessWidget {
  const DSRadioGroup({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.direction = Axis.vertical,
    this.spacing = 0,
  });

  final T? value;
  final List<DSRadioItem<T>> items;
  final ValueChanged<T?> onChanged;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final children = items.map((item) {
      return _DSRadioTile<T>(
        item: item,
        groupValue: value,
        onChanged: item.enabled ? onChanged : null,
      );
    }).toList();

    if (direction == Axis.horizontal) {
      return Row(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            Expanded(child: children[i]),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(height: spacing),
          children[i],
        ],
      ],
    );
  }
}

class _DSRadioTile<T> extends StatelessWidget {
  const _DSRadioTile({
    required this.item,
    required this.groupValue,
    this.onChanged,
  });

  final DSRadioItem<T> item;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.enabled && onChanged != null
          ? () => onChanged!(item.value)
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: item.description != null
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Radio<T>(
              value: item.value,
              groupValue: groupValue,
              onChanged: item.enabled ? onChanged : null,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: item.enabled
                              ? null
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withOpacity(0.4),
                        ),
                  ),
                  if (item.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      item.description!,
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
}
