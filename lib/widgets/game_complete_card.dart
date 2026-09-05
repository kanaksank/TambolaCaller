import 'package:flutter/material.dart';

import '../services/game_controller.dart';
import '../theme/app_theme.dart';

/// Shown on the caller screen once all 90 numbers have been called.
class GameCompleteCard extends StatelessWidget {
  const GameCompleteCard({super.key, required this.onNewGame});

  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'ALL NUMBERS CALLED',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${GameController.totalNumbers} / ${GameController.totalNumbers}',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: scheme.primary,
                    ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 62,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onNewGame,
                  icon: const Icon(Icons.restart_alt_rounded, size: 26),
                  label: const Text(
                    'START NEW GAME',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
