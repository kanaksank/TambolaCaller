import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The full 1-90 board in a fixed 10-column grid.
///
/// States never rely on colour alone: a called number also carries a check
/// mark, and the current number is ringed, shadowed and set in a heavier
/// weight than everything around it.
class NumberGrid extends StatelessWidget {
  const NumberGrid({
    super.key,
    required this.calledNumbers,
    required this.currentNumber,
    this.total = 90,
    this.columns = 10,
  });

  final Set<int> calledNumbers;
  final int? currentNumber;
  final int total;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: total,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
      ),
      itemBuilder: (BuildContext context, int index) {
        final int number = index + 1;
        return NumberCell(
          number: number,
          isCalled: calledNumbers.contains(number),
          isCurrent: number == currentNumber,
        );
      },
    );
  }
}

class NumberCell extends StatelessWidget {
  const NumberCell({
    super.key,
    required this.number,
    required this.isCalled,
    required this.isCurrent,
  });

  final int number;
  final bool isCalled;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    late final Color background;
    late final Color foreground;
    late final Color borderColor;
    late final double borderWidth;

    if (isCurrent) {
      background = AppTheme.accent;
      foreground = AppTheme.onAccent;
      borderColor = AppTheme.onAccent;
      borderWidth = 3;
    } else if (isCalled) {
      background = scheme.primaryContainer;
      foreground = scheme.onPrimaryContainer;
      borderColor = scheme.primary;
      borderWidth = 1.5;
    } else {
      background = scheme.surfaceContainerHighest;
      foreground = scheme.onSurfaceVariant;
      borderColor = scheme.outlineVariant;
      borderWidth = 1;
    }

    return Semantics(
      label: isCurrent
          ? 'Number $number, current call'
          : isCalled
              ? 'Number $number, called'
              : 'Number $number, not called',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: borderWidth),
          boxShadow: isCurrent
              ? <BoxShadow>[
                  BoxShadow(
                    color: AppTheme.accent.withAlpha(140),
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Center(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: Text(
                    '$number',
                    style: TextStyle(
                      color: foreground,
                      height: 1,
                      fontWeight: isCurrent
                          ? FontWeight.w900
                          : isCalled
                              ? FontWeight.w700
                              : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            if (isCalled && !isCurrent)
              Positioned(
                top: 1,
                right: 1,
                child: Icon(Icons.check_rounded, size: 11, color: foreground),
              ),
            if (isCurrent)
              Positioned(
                top: 1,
                right: 1,
                child: Icon(
                  Icons.campaign_rounded,
                  size: 12,
                  color: AppTheme.onAccent,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Explains the three cell states without relying on colour.
class BoardLegend extends StatelessWidget {
  const BoardLegend({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _LegendItem(
          label: 'Not called',
          background: scheme.surfaceContainerHighest,
          border: scheme.outlineVariant,
          foreground: scheme.onSurfaceVariant,
        ),
        _LegendItem(
          label: 'Called',
          background: scheme.primaryContainer,
          border: scheme.primary,
          foreground: scheme.onPrimaryContainer,
          icon: Icons.check_rounded,
        ),
        _LegendItem(
          label: 'Current',
          background: AppTheme.accent,
          border: AppTheme.onAccent,
          foreground: AppTheme.onAccent,
          icon: Icons.campaign_rounded,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.label,
    required this.background,
    required this.border,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color border;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: border, width: 1.5),
          ),
          child: icon == null
              ? null
              : Icon(icon, size: 13, color: foreground),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
