import 'package:flutter/material.dart';

import '../models/announcement.dart';

/// The words under the ball — exactly what the caller is saying out loud.
class AnnouncementText extends StatelessWidget {
  const AnnouncementText({
    super.key,
    required this.announcement,
    this.compact = false,
  });

  final Announcement? announcement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Announcement? call = announcement;

    if (call == null) {
      return Text(
        'TAP GENERATE TO CALL THE FIRST NUMBER',
        textAlign: TextAlign.center,
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
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            call.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 26 : 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.6,
              color: scheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            call.detail,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 15 : 18,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
