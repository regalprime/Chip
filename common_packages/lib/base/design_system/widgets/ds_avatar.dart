import 'package:flutter/material.dart';

/// A themed avatar with network image, initials fallback, or icon fallback.
///
/// Usage:
/// ```dart
/// DSAvatar(
///   imageUrl: user.photoUrl,
///   name: user.displayName,
///   size: 48,
/// )
///
/// DSAvatar(
///   imageUrl: null,
///   name: 'John Doe',  // Shows "JD"
///   size: 40,
/// )
///
/// DSAvatar.icon(
///   icon: Icons.group,
///   size: 56,
/// )
/// ```
class DSAvatar extends StatelessWidget {
  const DSAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.onTap,
  }) : _icon = null;

  const DSAvatar.icon({
    super.key,
    required IconData icon,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
    this.onTap,
  })  : _icon = icon,
        imageUrl = null,
        name = null;

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final BoxBorder? border;
  final VoidCallback? onTap;
  final IconData? _icon;

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = backgroundColor ?? colorScheme.primaryContainer;
    final fgColor = foregroundColor ?? colorScheme.onPrimaryContainer;

    Widget avatar;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    } else if (_icon != null) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Icon(_icon, size: size * 0.5, color: fgColor),
      );
    } else if (name != null && name!.isNotEmpty) {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Text(
          _getInitials(name!),
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: size / 2,
        backgroundColor: bgColor,
        child: Icon(Icons.person, size: size * 0.5, color: fgColor),
      );
    }

    if (border != null) {
      avatar = Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: border,
        ),
        child: avatar,
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatar,
      );
    }

    return avatar;
  }
}

/// A row of overlapping avatars for showing group members.
///
/// Usage:
/// ```dart
/// DSAvatarStack(
///   avatars: users.map((u) => DSAvatar(imageUrl: u.photoUrl, name: u.name, size: 32)).toList(),
///   maxDisplay: 3,
///   overlapFactor: 0.3,
/// )
/// ```
class DSAvatarStack extends StatelessWidget {
  const DSAvatarStack({
    super.key,
    required this.avatars,
    this.maxDisplay = 4,
    this.overlapFactor = 0.3,
  });

  final List<DSAvatar> avatars;
  final int maxDisplay;
  final double overlapFactor;

  @override
  Widget build(BuildContext context) {
    final displayCount =
        avatars.length > maxDisplay ? maxDisplay : avatars.length;
    final remaining = avatars.length - displayCount;
    final size = avatars.isNotEmpty ? avatars.first.size : 32.0;
    final overlap = size * overlapFactor;

    return SizedBox(
      height: size,
      width: size + (displayCount - 1 + (remaining > 0 ? 1 : 0)) * (size - overlap),
      child: Stack(
        children: [
          for (int i = 0; i < displayCount; i++)
            Positioned(
              left: i * (size - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: avatars[i],
              ),
            ),
          if (remaining > 0)
            Positioned(
              left: displayCount * (size - overlap),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: size / 2,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Text(
                    '+$remaining',
                    style: TextStyle(
                      fontSize: size * 0.3,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
