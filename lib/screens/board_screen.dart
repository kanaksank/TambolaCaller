import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../services/game_controller.dart';
import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/number_grid.dart';

/// Every number from 1 to 90, with called, current and uncalled states.
class BoardScreen extends StatelessWidget {
  const BoardScreen({super.key});

  static const double _spacing = 6;
  static const int _columns = 10;
  static const int _rows = 9;

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);
    final Set<int> called = game.calledNumbers.toSet();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const AppHeader(title: 'NUMBER BOARD'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              children: <Widget>[
                const Flexible(child: BoardLegend()),
                const Spacer(),
                Text(
                  'REMAINING ${game.remainingCount}',
                  style: AppTheme.sectionLabel(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final double byWidth =
                      (constraints.maxWidth - _spacing * (_columns - 1)) /
                          _columns;
                  final double byHeight =
                      (constraints.maxHeight - _spacing * (_rows - 1)) / _rows;

                  double cell = math.min(byWidth, byHeight);
                  final bool needsScroll = cell < 26;
                  if (needsScroll) cell = math.min(byWidth, 26);

                  final Widget grid = SizedBox(
                    width: cell * _columns + _spacing * (_columns - 1),
                    child: NumberGrid(
                      calledNumbers: called,
                      currentNumber: game.currentNumber,
                    ),
                  );

                  if (needsScroll) {
                    return SingleChildScrollView(
                      child: Center(child: grid),
                    );
                  }
                  return Center(child: grid);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
