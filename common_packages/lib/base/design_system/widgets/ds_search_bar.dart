import 'dart:async';

import 'package:flutter/material.dart';

/// A themed search bar with debounce support.
///
/// Usage:
/// ```dart
/// DSSearchBar(
///   hint: 'Search users...',
///   onChanged: (query) => bloc.add(SearchEvent(query)),
/// )
///
/// DSSearchBar(
///   hint: 'Search...',
///   onChanged: (query) {},
///   debounceMs: 500,
///   autofocus: true,
/// )
/// ```
class DSSearchBar extends StatefulWidget {
  const DSSearchBar({
    super.key,
    this.hint = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.debounceMs = 300,
    this.autofocus = false,
    this.enabled = true,
    this.prefixIcon = Icons.search,
    this.showClearButton = true,
  });

  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextEditingController? controller;
  final int debounceMs;
  final bool autofocus;
  final bool enabled;
  final IconData prefixIcon;
  final bool showClearButton;

  @override
  State<DSSearchBar> createState() => _DSSearchBarState();
}

class _DSSearchBarState extends State<DSSearchBar> {
  late TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {}); // Rebuild to show/hide clear button
    if (widget.onChanged == null) return;

    _debounce?.cancel();
    _debounce = Timer(
      Duration(milliseconds: widget.debounceMs),
      () => widget.onChanged!(value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextField(
      controller: _controller,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      onChanged: _onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: Icon(widget.prefixIcon, size: 20),
        suffixIcon: widget.showClearButton && _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _controller.clear();
                  _onChanged('');
                },
              )
            : null,
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
