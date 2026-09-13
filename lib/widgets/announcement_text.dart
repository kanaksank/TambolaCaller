import 'package:flutter/material.dart';

import '../models/announcement.dart';

/// Exactly what the caller is saying out loud, in words.
class AnnouncementText extends StatelessWidget {
  const AnnouncementText({
    super.key,
    required this.announcement,
    this.compact = false,
    this.alignStart = false,
  });

  final Announcement? announcement;

  /// Smaller type, for when the text shares its space with something else.
  final bool compact;

  /// Left-align instead of centring — used by the landscape side column.
  final bool alignStart;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Announcement? call = announcement;
    final TextAlign textAlign = alignStart ? TextAlign.start : TextAlign.center;
    final Alignment boxAlign =
        alignStart ? Alignment.centerLeft : Alignment.center;

    if (call == null) {
      return Text(
        'TAP GENERATE TO CALL THE FIRST NUMBER',
        textAlign: textAlign,
        style: TextStyle(
          fontSize: compact ? 15 : 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
          color: scheme.onSurfaceVariant,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: boxAlign,
          child: Text(
            call.title,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: compact ? 23 : 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: boxAlign,
          child: Text(
            call.detail,
            textAlign: textAlign,
            style: TextStyle(
              fontSize: compact ? 14 : 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
