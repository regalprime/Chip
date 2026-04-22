import 'package:common_packages/constants/app_colors_extension.dart';
import 'package:flutter/material.dart';

/// A themed card container matching the app's design language.
///
/// Usage:
/// ```dart
/// DSCard(
///   child: Text('Hello'),
/// )
///
/// DSCard(
///   padding: EdgeInsets.all(20),
///   onTap: () {},
///   child: Row(children: [...]),
/// )
///
/// DSCard.outlined(
///   child: ListTile(title: Text('Item')),
/// )
/// ```
class DSCard extends StatelessWidget {
  const DSCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.elevation,
    this.clipBehavior = Clip.antiAlias,
  }) : _variant = _DSCardVariant.filled;

  const DSCard.outlined({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.onLongPress,
    this.color,
    this.borderColor,
    this.clipBehavior = Clip.antiAlias,
  })  : elevation = 0,
        _variant = _DSCardVariant.outlined;

  const DSCard.flat({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.borderRadius = 16,
    this.onTap,
    this.onLongPress,
    this.color,
    this.clipBehavior = Clip.antiAlias,
  })  : elevation = 0,
        borderColor = null,
        _variant = _DSCardVariant.flat;

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;
  final Color? borderColor;
  final double? elevation;
  final Clip clipBehavior;
  final _DSCardVariant _variant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColorsExtension>();

    final cardColor = color ?? appColors?.card ?? theme.cardColor;
    final border = _variant == _DSCardVariant.outlined
        ? Border.all(
            color: borderColor ?? appColors?.divider ?? theme.dividerColor,
          )
        : _variant == _DSCardVariant.filled
            ? null
            : null;

    final decoration = BoxDecoration(
      color: cardColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: border,
      boxShadow: (elevation ?? 0) > 0
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: elevation! * 2,
                offset: Offset(0, elevation!),
              ),
            ]
          : null,
    );

    Widget result = Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: clipBehavior,
      child: Padding(
        padding: padding,
        child: child,
      ),
    );

    if (onTap != null || onLongPress != null) {
      result = Container(
        margin: margin,
        clipBehavior: clipBehavior,
        decoration: decoration,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            onLongPress: onLongPress,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Padding(
              padding: padding,
              child: child,
            ),
          ),
        ),
      );
    }

    return result;
  }
}

enum _DSCardVariant { filled, outlined, flat }
