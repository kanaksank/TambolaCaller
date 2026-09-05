import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The last few calls, newest first and clearly highlighted.
class RecentNumbers extends StatelessWidget {
  const RecentNumbers({
    super.key,
    required this.numbers,
    this.compact = false,
    this.horizontal = false,
  });

  /// Newest number first.
  final List<int> numbers;

  /// Slightly smaller chips, used in the landscape side panel.
  final bool compact;

  /// Lay the chips out in one scrollable row instead of wrapping.
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text('RECENT NUMBERS', style: AppTheme.sectionLabel(context)),
        const SizedBox(height: 10),
        if (numbers.isEmpty)
          Text(
            'No numbers called yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          )
        else if (horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: <Widget>[
                for (int i = 0; i < numbers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _RecentChip(
                      number: numbers[i],
                      isNewest: i == 0,
                      compact: compact,
                    ),
                  ),
              ],
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: <Widget>[
              for (int i = 0; i < numbers.length; i++)
                _RecentChip(
                  number: numbers[i],
                  isNewest: i == 0,
                  compact: compact,
                ),
            ],
          ),
      ],
    );
  }
}

class _RecentChip extends StatelessWidget {
  const _RecentChip({
    required this.number,
    required this.isNewest,
    required this.compact,
  });

  final int number;
  final bool isNewest;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final double size = compact ? 46 : 54;

    return Semantics(
      label: isNewest ? 'Latest number $number' : 'Number $number',
      child: Container(
        width: isNewest ? size + 6 : size,
        height: isNewest ? size + 6 : size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isNewest ? AppTheme.accent : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isNewest ? AppTheme.onAccent : scheme.outlineVariant,
            width: isNewest ? 2.5 : 1,
          ),
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: isNewest ? (compact ? 22 : 26) : (compact ? 18 : 21),
            fontWeight: isNewest ? FontWeight.w900 : FontWeight.w700,
            color: isNewest ? AppTheme.onAccent : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}
