import 'dart:math';

import '../models/housie_ticket.dart';
import 'ticket_validation.dart';

/// Builds valid six-ticket Housie strips.
///
/// The six tickets of a strip are generated together, never independently,
/// because between them they must carry 1-90 exactly once. That happens in
/// three steps:
///
///   1. **Share out each column.** Column 0 holds nine numbers (1-9), columns
///      1-7 hold ten each, column 8 holds eleven (80-90). Every ticket must
///      take at least one number from every column, which accounts for six of
///      them; the rest are handed out in shares of one or two so that no
///      ticket ends up with more than three numbers in a column, and so that
///      every ticket's nine columns add up to exactly fifteen numbers.
///   2. **Choose rows.** Within a ticket, a column taking `k` numbers occupies
///      `k` of the three rows, and each row must end up with exactly five
///      numbers. Columns are filled widest first into the rows with the most
///      space left, which keeps the row counts balanced.
///   3. **Deal the numbers.** Each column's numbers are shuffled once for the
///      whole strip and dealt out in order, then sorted top to bottom inside
///      each ticket's column.
///
/// Any attempt that cannot satisfy the constraints is thrown away and retried,
/// and every strip is validated before it is returned.
class TicketGenerator {
  TicketGenerator({Random? random})
      : _random = random ?? Random(Random.secure().nextInt(1 << 32));

  /// Attempts are cheap (a fraction of a millisecond) and in practice succeed
  /// within two, so this ceiling is only a guard against an impossible state.
  static const int maxAttempts = 500;

  final Random _random;

  /// A validated strip of six tickets covering 1-90 exactly once.
  TicketStrip generateStrip() {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final TicketStrip? strip = _buildStrip();
      if (strip != null && TicketValidation.isValidStrip(strip)) {
        return strip;
      }
    }
    throw StateError(
      'Could not build a valid six-ticket strip in $maxAttempts attempts.',
    );
  }

  /// One printed page: two independent strips, twelve tickets.
  TicketPage generatePage() => TicketPage(<TicketStrip>[
        generateStrip(),
        generateStrip(),
      ]);

  TicketDocument generateDocument(int pageCount) {
    if (pageCount < 1) {
      throw ArgumentError.value(pageCount, 'pageCount', 'must be at least 1');
    }
    return TicketDocument(<TicketPage>[
      for (int page = 0; page < pageCount; page++) generatePage(),
    ]);
  }

  // --------------------------------------------------------------- internals

  TicketStrip? _buildStrip() {
    final List<List<int>>? counts = _columnCounts();
    if (counts == null) return null;

    // One shuffled pool per column, dealt out across the six tickets.
    final List<List<int>> pools = <List<int>>[
      for (int column = 0; column < HousieRules.columns; column++)
        <int>[
          for (int number = HousieRules.columnStart[column];
              number <= HousieRules.columnEnd[column];
              number++)
            number,
        ]..shuffle(_random),
    ];
    final List<int> dealt = List<int>.filled(HousieRules.columns, 0);

    final List<HousieTicket> tickets = <HousieTicket>[];
    for (int t = 0; t < HousieRules.ticketsPerStrip; t++) {
      final List<List<bool>>? occupied = _rowPlacement(counts[t]);
      if (occupied == null) return null;

      final List<List<int?>> grid = List<List<int?>>.generate(
        HousieRules.rows,
        (_) => List<int?>.filled(HousieRules.columns, null),
      );

      for (int column = 0; column < HousieRules.columns; column++) {
        final int take = counts[t][column];
        final List<int> picked =
            pools[column].sublist(dealt[column], dealt[column] + take)..sort();
        dealt[column] += take;

        int next = 0;
        for (int row = 0; row < HousieRules.rows; row++) {
          if (occupied[row][column]) {
            grid[row][column] = picked[next++];
          }
        }
      }
      tickets.add(HousieTicket(grid));
    }

    return TicketStrip(tickets);
  }

  /// How many numbers each ticket takes from each column: a 6 × 9 table whose
  /// rows add up to 15 and whose columns add up to the size of the range.
  ///
  /// Returns `null` when the shares cannot be placed, which the caller retries.
  List<List<int>>? _columnCounts() {
    final List<List<int>> extra = List<List<int>>.generate(
      HousieRules.ticketsPerStrip,
      (_) => List<int>.filled(HousieRules.columns, 0),
    );
    // Fifteen numbers, minus the one per column every ticket already holds.
    final List<int> remaining = List<int>.filled(
      HousieRules.ticketsPerStrip,
      HousieRules.numbersPerTicket - HousieRules.columns,
    );

    final List<int> order = <int>[
      for (int column = 0; column < HousieRules.columns; column++) column,
    ]..shuffle(_random);

    for (final int column in order) {
      final int spare =
          HousieRules.columnSize(column) - HousieRules.ticketsPerStrip;

      for (final int share in _shares(spare)) {
        final List<int> candidates = <int>[
          for (int t = 0; t < HousieRules.ticketsPerStrip; t++) t,
        ]..shuffle(_random);
        // Widest share to the ticket with the most room left.
        candidates.sort((int a, int b) => remaining[b].compareTo(remaining[a]));

        bool placed = false;
        for (final int t in candidates) {
          if (extra[t][column] == 0 && remaining[t] >= share) {
            extra[t][column] = share;
            remaining[t] -= share;
            placed = true;
            break;
          }
        }
        if (!placed) return null;
      }
    }

    if (remaining.any((int left) => left != 0)) return null;

    return <List<int>>[
      for (int t = 0; t < HousieRules.ticketsPerStrip; t++)
        <int>[
          for (int column = 0; column < HousieRules.columns; column++)
            1 + extra[t][column],
        ],
    ];
  }

  /// Splits a column's spare numbers into per-ticket shares of one or two.
  ///
  /// Mostly ones, so two numbers in a column is the common case, with the
  /// occasional two keeping full columns of three in the mix — roughly one
  /// ticket column in twelve, which is about what a printed strip looks like.
  List<int> _shares(int spare) {
    final double roll = _random.nextDouble();
    int doubles = 0;
    if (roll > 0.90) {
      doubles = 2;
    } else if (roll > 0.55) {
      doubles = 1;
    }
    doubles = min(doubles, spare ~/ 2);

    return <int>[
      ...List<int>.filled(doubles, 2),
      ...List<int>.filled(spare - 2 * doubles, 1),
    ];
  }

  /// Which rows each column occupies in one ticket, given its column counts.
  ///
  /// Returns `null` if the rows cannot be balanced to five numbers each.
  List<List<bool>>? _rowPlacement(List<int> counts) {
    final List<List<bool>> occupied = List<List<bool>>.generate(
      HousieRules.rows,
      (_) => List<bool>.filled(HousieRules.columns, false),
    );
    final List<int> space =
        List<int>.filled(HousieRules.rows, HousieRules.numbersPerRow);

    final List<int> columns = <int>[
      for (int column = 0; column < HousieRules.columns; column++) column,
    ]..shuffle(_random);
    // Columns needing all three rows first, then pairs, then singles.
    columns.sort((int a, int b) => counts[b].compareTo(counts[a]));

    for (final int column in columns) {
      final List<int> rows = <int>[
        for (int row = 0; row < HousieRules.rows; row++) row,
      ]..shuffle(_random);
      rows.sort((int a, int b) => space[b].compareTo(space[a]));

      final List<int> chosen = rows.take(counts[column]).toList();
      if (chosen.any((int row) => space[row] <= 0)) return null;

      for (final int row in chosen) {
        occupied[row][column] = true;
        space[row]--;
      }
    }

    if (space.any((int left) => left != 0)) return null;
    return occupied;
  }
}
