import 'package:flutter/material.dart';

/// Loading indicator variants.
///
/// Usage:
/// ```dart
/// // Full-screen centered loading
/// DSLoading()
///
/// // Inline loading with message
/// DSLoading.inline(message: 'Loading data...')
///
/// // Overlay loading (blocks interaction)
/// Stack(
///   children: [
///     MyContent(),
///     if (isLoading) DSLoading.overlay(),
///   ],
/// )
///
/// // Skeleton placeholder
/// DSLoading.skeleton(width: 200, height: 16)
/// ```
class DSLoading extends StatelessWidget {
  const DSLoading({
    super.key,
    this.message,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
  })  : _variant = _DSLoadingVariant.center;

  const DSLoading.inline({
    super.key,
    this.message,
    this.size = 20,
    this.strokeWidth = 2,
    this.color,
  }) : _variant = _DSLoadingVariant.inline;

  const DSLoading.overlay({
    super.key,
    this.message,
    this.size = 32,
    this.strokeWidth = 3,
    this.color,
  }) : _variant = _DSLoadingVariant.overlay;

  final String? message;
  final double size;
  final double strokeWidth;
  final Color? color;
  final _DSLoadingVariant _variant;

  @override
  Widget build(BuildContext context) {
    final indicator = SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        color: color,
      ),
    );

    final content = message != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(height: 12),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
          )
        : indicator;

    switch (_variant) {
      case _DSLoadingVariant.center:
        return Center(child: content);

      case _DSLoadingVariant.inline:
        if (message != null) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              indicator,
              const SizedBox(width: 10),
              Text(
                message!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                    ),
              ),
            ],
          );
        }
        return indicator;

      case _DSLoadingVariant.overlay:
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(child: content),
          ),
        );
    }
  }
}

enum _DSLoadingVariant { center, inline, overlay }

/// A skeleton/shimmer placeholder for loading states.
///
/// Usage:
/// ```dart
/// DSSkeleton(width: 200, height: 16)
/// DSSkeleton(width: double.infinity, height: 48, borderRadius: 12)
/// DSSkeleton.circle(size: 40)
/// ```
class DSSkeleton extends StatelessWidget {
  const DSSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  }) : _isCircle = false;

  const DSSkeleton.circle({
    super.key,
    required double size,
  })  : width = size,
        height = size,
        borderRadius = 0,
        _isCircle = true;

  final double width;
  final double height;
  final double borderRadius;
  final bool _isCircle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.08)
            : Colors.black.withOpacity(0.08),
        borderRadius:
            _isCircle ? null : BorderRadius.circular(borderRadius),
        shape: _isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
    );
  }
}
