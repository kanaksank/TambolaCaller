import 'package:flutter/material.dart';

import '../models/housie_ticket.dart';

/// An on-screen Housie ticket, drawn the way it will print: a 3 × 9 grid with
/// strong lines, blank cells left empty and the numbers set bold.
class TicketPreview extends StatelessWidget {
  const TicketPreview({super.key, required this.ticket, this.label});

  final HousieTicket ticket;

  /// Optional identifier shown under the grid, e.g. `T001`.
  final String? label;

  static const double _outerBorder = 2;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final String? label = this.label;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 360;
        final double cellWidth =
            (width - _outerBorder * 2) / HousieRules.columns;
        final double cellHeight = cellWidth * 1.15;
        final double fontSize = cellWidth * 0.46;
        final BorderSide line = BorderSide(color: scheme.outlineVariant);

        return Container(
          width: width,
          decoration: BoxDecoration(
            color: scheme.surface,
            border: Border.all(color: scheme.onSurface, width: _outerBorder),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int row = 0; row < HousieRules.rows; row++)
                Row(
                  children: <Widget>[
                    for (int col = 0; col < HousieRules.columns; col++)
                      Container(
                        width: cellWidth,
                        height: cellHeight,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: col == HousieRules.columns - 1
                                ? BorderSide.none
                                : line,
                            bottom:
                                row == HousieRules.rows - 1 ? BorderSide.none : line,
                          ),
                        ),
                        child: ticket.at(row, col) == null
                            ? null
                            : Text(
                                '${ticket.at(row, col)}',
                                style: TextStyle(
                                  fontSize: fontSize,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                      ),
                  ],
                ),
              if (label != null)
                Container(
                  width: width - _outerBorder * 2,
                  padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
                  alignment: Alignment.centerRight,
                  decoration: BoxDecoration(border: Border(top: line)),
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
