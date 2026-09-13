import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The single most important element in the app: the current number, sized to
/// the circle that holds it and centred on it exactly.
///
/// Rather than guessing a font size, the label is measured and then scaled so
/// the rectangle its digits occupy has the same diagonal as a "safe" circle
/// inset from the rim. That uses the width a circle has to spare at its left
/// and right edges — where an inscribed square wastes it — while keeping a
/// visible margin between the glyphs and the border on every side.
class NumberBall extends StatelessWidget {
  const NumberBall({super.key, this.number});

  /// `null` before the first number of a game has been generated.
  final int? number;

  /// Cap height of a digit as a fraction of the font size. Roboto's is 0.711;
  /// rounding up keeps the fit conservative on other system fonts.
  static const double _digitCapHeight = 0.72;

  /// Clear space kept between the digits and the inside of the rim, as a
  /// fraction of the diameter.
  static const double _rimMargin = 0.06;

  /// Size the label is measured at before being scaled to the circle.
  static const double _referenceFontSize = 100;

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
        final double borderWidth = hasNumber ? diameter * 0.02 : 2;

        final TextStyle style = TextStyle(
          fontSize: _referenceFontSize,
          fontWeight: FontWeight.w900,
          height: 1,
          color: hasNumber ? AppTheme.onAccent : scheme.onSurfaceVariant,
        );

        double fontSize = diameter * 0.40;
        double baselineNudge = 0;

        if (hasNumber) {
          final double safeRadius =
              diameter / 2 - borderWidth - diameter * _rimMargin;

          final TextPainter painter = TextPainter(
            text: TextSpan(text: label, style: style),
            textDirection: Directionality.of(context),
            textScaler: TextScaler.noScaling,
            maxLines: 1,
          )..layout();

          const double inkHeight = _referenceFontSize * _digitCapHeight;
          final double inkWidth = painter.width;
          final double scale = 2 *
              safeRadius /
              math.sqrt(inkWidth * inkWidth + inkHeight * inkHeight);

          // Digits carry no descender, so their ink sits above the middle of
          // the line box. Shifting by the measured baseline puts the centre of
          // the glyphs on the centre of the circle.
          final double baseline =
              painter.computeDistanceToActualBaseline(TextBaseline.alphabetic);
          baselineNudge =
              (painter.height / 2 - (baseline - inkHeight / 2)) * scale;
          painter.dispose();

          // The line box is taller than the ink it holds, so cap the font size
          // to keep that box inside the circle as well.
          fontSize = math.min(_referenceFontSize * scale, diameter * 0.98);
        }

        return Center(
          child: Container(
            width: diameter,
            height: diameter,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: hasNumber ? AppTheme.accent : scheme.surfaceContainerHighest,
              border: Border.all(
                color: hasNumber ? AppTheme.onAccent : scheme.outlineVariant,
                width: borderWidth,
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withAlpha(hasNumber ? 46 : 18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: Transform.translate(
                key: ValueKey<String>(label),
                offset: Offset(0, baselineNudge),
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  textAlign: TextAlign.center,
                  // The circle sizes the digits; OS font scaling would break
                  // the fit it was measured for.
                  textScaler: TextScaler.noScaling,
                  style: style.copyWith(fontSize: fontSize),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
