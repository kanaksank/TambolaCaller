import 'package:flutter/material.dart';

import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/number_ball.dart';

/// Shown once, on the very first launch.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(
                    height: 160,
                    width: 160,
                    child: NumberBall(number: 90),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'WELCOME TO\nTAMBOLA CALLER',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.4,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Generate numbers, call them aloud and keep track of '
                    'every number from 1 to 90.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    height: 64,
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => GameScope.read(context).markWelcomeSeen(),
                      child: const Text(
                        'START GAME',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Works completely offline. Landscape is recommended so the '
                    'whole room can read the number.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppTheme.radius / 2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
