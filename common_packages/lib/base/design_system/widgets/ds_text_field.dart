import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A unified text input component.
///
/// Usage:
/// ```dart
/// DSTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   prefixIcon: Icons.email_outlined,
///   controller: _emailController,
///   keyboardType: TextInputType.emailAddress,
///   validator: (v) => v!.isEmpty ? 'Required' : null,
/// )
///
/// DSTextField.password(
///   label: 'Password',
///   controller: _passwordController,
/// )
///
/// DSTextField.multiline(
///   label: 'Notes',
///   controller: _notesController,
///   maxLines: 5,
/// )
/// ```
class DSTextField extends StatefulWidget {
  const DSTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.focusNode,
    this.initialValue,
    this.borderRadius = 12,
    this.filled = false,
  }) : _isPassword = false;

  const DSTextField._password({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.initialValue,
    this.borderRadius = 12,
    this.filled = false,
  })  : _isPassword = true,
        obscureText = true,
        prefixIcon = Icons.lock_outline,
        suffixIcon = null,
        onSuffixTap = null,
        maxLines = 1,
        minLines = null,
        keyboardType = null,
        textCapitalization = TextCapitalization.none,
        inputFormatters = null,
        onTap = null;

  /// Creates a password field with built-in visibility toggle.
  static Widget password({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    String? errorText,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    int? maxLength,
    TextInputAction? textInputAction,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onFieldSubmitted,
    FocusNode? focusNode,
    String? initialValue,
    double borderRadius = 12,
    bool filled = false,
  }) {
    return _DSPasswordField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLength: maxLength,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      initialValue: initialValue,
      borderRadius: borderRadius,
      filled: filled,
    );
  }

  /// Creates a multiline text field.
  static DSTextField multiline({
    Key? key,
    TextEditingController? controller,
    String? label,
    String? hint,
    String? helperText,
    String? errorText,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    int maxLines = 5,
    int? minLines,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    String? Function(String?)? validator,
    ValueChanged<String>? onChanged,
    FocusNode? focusNode,
    String? initialValue,
    double borderRadius = 12,
    bool filled = false,
  }) {
    return DSTextField(
      key: key,
      controller: controller,
      label: label,
      hint: hint,
      helperText: helperText,
      errorText: errorText,
      enabled: enabled,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      minLines: minLines ?? 3,
      maxLength: maxLength,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      textCapitalization: textCapitalization,
      validator: validator,
      onChanged: onChanged,
      focusNode: focusNode,
      initialValue: initialValue,
      borderRadius: borderRadius,
      filled: filled,
    );
  }

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onTap;
  final FocusNode? focusNode;
  final String? initialValue;
  final double borderRadius;
  final bool filled;
  final bool _isPassword;

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.initialValue,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      onTap: widget.onTap,
      focusNode: widget.focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon, size: 20)
            : null,
        suffixIcon: widget.suffixIcon != null
            ? IconButton(
                icon: Icon(widget.suffixIcon, size: 20),
                onPressed: widget.onSuffixTap,
              )
            : null,
        filled: widget.filled,
        fillColor: widget.filled
            ? colorScheme.surfaceContainerHighest.withOpacity(0.5)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.2)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

/// Internal password field with built-in visibility toggle.
class _DSPasswordField extends StatefulWidget {
  const _DSPasswordField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLength,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.focusNode,
    this.initialValue,
    this.borderRadius = 12,
    this.filled = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final int? maxLength;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final FocusNode? focusNode;
  final String? initialValue;
  final double borderRadius;
  final bool filled;

  @override
  State<_DSPasswordField> createState() => _DSPasswordFieldState();
}

class _DSPasswordFieldState extends State<_DSPasswordField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return DSTextField(
      controller: widget.controller,
      label: widget.label ?? 'Password',
      hint: widget.hint,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      onSuffixTap: () => setState(() => _obscure = !_obscure),
      obscureText: _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      maxLength: widget.maxLength,
      textInputAction: widget.textInputAction,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onFieldSubmitted,
      focusNode: widget.focusNode,
      initialValue: widget.initialValue,
      borderRadius: widget.borderRadius,
      filled: widget.filled,
    );
  }
}
