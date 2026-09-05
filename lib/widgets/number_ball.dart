import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The single most important element in the app: the current number, as big as
/// the available space allows so it can be read from across the room.
class NumberBall extends StatelessWidget {
  const NumberBall({super.key, this.number});

  /// `null` before the first number of a game has been generated.
  final int? number;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final bool hasNumber = number != null;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double diameter = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 320,
        );

        return Center(
          child: Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasNumber ? AppTheme.accent : scheme.surfaceContainerHighest,
              border: Border.all(
                color: hasNumber ? AppTheme.onAccent : scheme.outlineVariant,
                width: hasNumber ? diameter * 0.02 : 2,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withAlpha(hasNumber ? 46 : 18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(diameter * 0.14),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: hasNumber
                    ? FittedBox(
                        key: ValueKey<int>(number!),
                        fit: BoxFit.contain,
                        child: Text(
                          '$number',
                          style: const TextStyle(
                            color: AppTheme.onAccent,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            letterSpacing: -2,
                          ),
                        ),
                      )
                    : FittedBox(
                        key: const ValueKey<String>('empty'),
                        fit: BoxFit.contain,
                        child: Text(
                          '--',
                          style: TextStyle(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
