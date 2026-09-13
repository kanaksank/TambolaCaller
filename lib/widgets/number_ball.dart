import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The single most important element in the app: the current number, as big as
/// the circle can physically hold so it reads from across the room.
///
/// The digits are sized from the ball's own geometry rather than from an
/// inscribed square — a wide two-digit call is allowed to run out towards the
/// left and right edges, where a circle has room to spare, instead of being
/// boxed in by the much smaller square that fits inside it.
class NumberBall extends StatelessWidget {
  const NumberBall({super.key, this.number});

  /// `null` before the first number of a game has been generated.
  final int? number;

  /// Font size as a fraction of the ball diameter, by number of characters.
  static const double _singleDigitScale = 0.94;
  static const double _doubleDigitScale = 0.74;
  static const double _placeholderScale = 0.42;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int? value = number;
    final bool hasNumber = value != null;
    final String label = hasNumber ? '$value' : '--';

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double diameter = math.min(
          constraints.maxWidth.isFinite ? constraints.maxWidth : 320,
          constraints.maxHeight.isFinite ? constraints.maxHeight : 320,
        );

        final double fontSize = diameter *
            (!hasNumber
                ? _placeholderScale
                : label.length == 1
                    ? _singleDigitScale
                    : _doubleDigitScale);

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
              // Just enough inset to clear the rim. The FittedBox below only
              // ever shrinks, so a font wider than Roboto is scaled down
              // rather than clipped by the circle.
              padding: EdgeInsets.symmetric(
                horizontal: diameter * 0.05,
                vertical: diameter * 0.03,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: FittedBox(
                  key: ValueKey<String>(label),
                  fit: BoxFit.scaleDown,
                  child: Transform.translate(
                    // Digits carry no descender, so the ink sits high in the
                    // line box; nudge it down to sit optically centred.
                    offset: Offset(0, fontSize * 0.06),
                    child: Text(
                      label,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: fontSize,
                        color: hasNumber
                            ? AppTheme.onAccent
                            : scheme.onSurfaceVariant,
                        fontWeight: FontWeight.w900,
                        height: 1,
                        letterSpacing: -fontSize * 0.04,
                      ),
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
