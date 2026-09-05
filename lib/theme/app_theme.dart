import 'package:flutter/material.dart';

/// A cheerful game-night palette that still reads as a professional product:
/// deep violet as the base, warm amber for the number that matters right now.
abstract final class AppTheme {
  static const Color seed = Color(0xFF5B3FBF);

  /// Highlight for the current number. Always paired with [onAccent].
  static const Color accent = Color(0xFFFFC73D);
  static const Color onAccent = Color(0xFF241B47);

  /// Corner radius used by the big cards and buttons.
  static const double radius = 24;

  static ThemeData light() => _build(Brightness.light);

  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final ColorScheme scheme =
        ColorScheme.fromSeed(seedColor: seed, brightness: brightness);

    final ButtonStyle roundedButton = ButtonStyle(
      shape: WidgetStatePropertyAll<OutlinedBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      filledButtonTheme: FilledButtonThemeData(style: roundedButton),
      outlinedButtonTheme: OutlinedButtonThemeData(style: roundedButton),
      splashFactory: InkSparkle.splashFactory,
      navigationBarTheme: NavigationBarThemeData(
        labelTextStyle: const WidgetStatePropertyAll<TextStyle>(
          TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.6),
        ),
        indicatorColor: scheme.primaryContainer,
      ),
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1),
    );
  }

  /// Letter-spaced, upper-case label style used for section headings.
  static TextStyle sectionLabel(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
  }
}
