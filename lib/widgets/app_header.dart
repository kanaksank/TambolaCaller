import 'package:flutter/material.dart';

import '../models/orientation_mode.dart';
import '../services/game_controller.dart';
import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import 'settings_sheet.dart';

/// Compact top bar: app name on the left, progress + controls on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    this.title = 'TAMBOLA CALLER',
    this.shortTitle = 'TAMBOLA',
  });

  final String title;

  /// Used instead of [title] when the controls need the room.
  final String shortTitle;

  /// Below this width the header trims itself rather than truncating the name.
  static const double _compactWidth = 420;

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final Size size = MediaQuery.sizeOf(context);
    final bool isLandscape = size.width > size.height;
    final bool compact = size.width < _compactWidth;

    final TextTheme text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              compact ? shortTitle : title,
              overflow: TextOverflow.ellipsis,
              style: (compact ? text.titleMedium : text.titleLarge)?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: scheme.onSurface,
              ),
            ),
          ),
          CalledCounter(
            called: game.calledCount,
            total: GameController.totalNumbers,
            compact: compact,
          ),
          const SizedBox(width: 6),
          Tooltip(
            message: game.voiceEnabled ? 'Voice on' : 'Voice off',
            child: Icon(
              game.voiceEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
              color: game.voiceEnabled ? scheme.primary : scheme.onSurfaceVariant,
              size: 26,
              semanticLabel:
                  game.voiceEnabled ? 'Voice announcement on' : 'Voice announcement off',
            ),
          ),
          // One tap flips the app the other way up. The icon shows where the
          // tap will take you, not where you already are.
          IconButton(
            onPressed: () => game.setOrientationMode(
              isLandscape ? OrientationMode.portrait : OrientationMode.landscape,
            ),
            icon: Icon(
              isLandscape
                  ? Icons.stay_current_portrait_rounded
                  : Icons.stay_current_landscape_rounded,
            ),
            iconSize: 26,
            tooltip: isLandscape ? 'Switch to portrait' : 'Switch to landscape',
          ),
          IconButton(
            onPressed: () => showGameSettings(context),
            icon: const Icon(Icons.settings_rounded),
            iconSize: 26,
            tooltip: 'Game controls',
          ),
        ],
      ),
    );
  }
}

class CalledCounter extends StatelessWidget {
  const CalledCounter({
    super.key,
    required this.called,
    required this.total,
    this.compact = false,
  });

  final int called;
  final int total;

  /// Drops the "CALLED" word, keeping just the tally.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (!compact) ...<Widget>[
            Text('CALLED', style: AppTheme.sectionLabel(context)),
            const SizedBox(width: 8),
          ],
          Text(
            '$called / $total',
            semanticsLabel: '$called of $total numbers called',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: scheme.onSurface,
                ),
          ),
        ],
      ),
    );
  }
}
