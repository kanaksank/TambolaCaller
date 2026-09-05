import 'package:flutter/material.dart';

import '../services/game_controller.dart';
import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import 'settings_sheet.dart';

/// Compact top bar: app name on the left, progress + controls on the right.
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, this.title = 'TAMBOLA CALLER'});

  final String title;

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      child: Row(
        children: <Widget>[
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: scheme.onSurface,
                  ),
            ),
          ),
          const Spacer(),
          CalledCounter(called: game.calledCount, total: GameController.totalNumbers),
          const SizedBox(width: 8),
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
  const CalledCounter({super.key, required this.called, required this.total});

  final int called;
  final int total;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('CALLED', style: AppTheme.sectionLabel(context)),
          const SizedBox(width: 8),
          Text(
            '$called / $total',
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
