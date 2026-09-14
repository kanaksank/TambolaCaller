/// The fixed shape of a Housie/Tambola ticket, and of a six-ticket strip.
abstract final class HousieRules {
  static const int rows = 3;
  static const int columns = 9;
  static const int numbersPerRow = 5;
  static const int numbersPerTicket = 15;
  static const int ticketsPerStrip = 6;
  static const int stripsPerPage = 2;
  static const int ticketsPerPage = ticketsPerStrip * stripsPerPage;
  static const int minNumber = 1;
  static const int maxNumber = 90;

  /// First number of each column: 1, 10, 20 … 80.
  static const List<int> columnStart = <int>[1, 10, 20, 30, 40, 50, 60, 70, 80];

  /// Last number of each column: 9, 19, 29 … 90. The last column carries the
  /// extra number, which is why a strip holds 9 + 7 × 10 + 11 = 90 numbers.
  static const List<int> columnEnd = <int>[9, 19, 29, 39, 49, 59, 69, 79, 90];

  static int columnSize(int column) =>
      columnEnd[column] - columnStart[column] + 1;

  /// The column a number belongs in. 90 shares the last column with the 80s.
  static int columnOf(int number) {
    final int column = number ~/ 10;
    return column >= columns ? columns - 1 : column;
  }

  static bool fitsColumn(int number, int column) =>
      number >= columnStart[column] && number <= columnEnd[column];
}

/// One ticket: three rows of nine cells, fifteen of which hold a number.
class HousieTicket {
  HousieTicket(List<List<int?>> grid)
      : grid = List<List<int?>>.unmodifiable(<List<int?>>[
          for (final List<int?> row in grid) List<int?>.unmodifiable(row),
        ]);

  /// `grid[row][column]`, with `null` for a blank cell.
  final List<List<int?>> grid;

  int? at(int row, int column) => grid[row][column];

  /// Every number on the ticket, ascending.
  List<int> get numbers {
    final List<int> found = <int>[
      for (final List<int?> row in grid)
        for (final int? value in row)
          if (value != null) value,
    ];
    found.sort();
    return found;
  }

  /// The numbers in one column, top to bottom.
  List<int> columnNumbers(int column) => <int>[
        for (int row = 0; row < grid.length; row++)
          if (grid[row][column] != null) grid[row][column]!,
      ];

  int numbersInRow(int row) =>
      grid[row].where((int? value) => value != null).length;
}

/// Six tickets that between them carry every number from 1 to 90 exactly once.
class TicketStrip {
  TicketStrip(List<HousieTicket> tickets)
      : tickets = List<HousieTicket>.unmodifiable(tickets);

  final List<HousieTicket> tickets;

  List<int> get numbers {
    final List<int> found = <int>[
      for (final HousieTicket ticket in tickets) ...ticket.numbers,
    ];
    found.sort();
    return found;
  }
}

/// One printed A4 page: two independent strips, twelve tickets.
class TicketPage {
  TicketPage(List<TicketStrip> strips)
      : strips = List<TicketStrip>.unmodifiable(strips);

  final List<TicketStrip> strips;

  List<HousieTicket> get tickets => <HousieTicket>[
        for (final TicketStrip strip in strips) ...strip.tickets,
      ];
}

/// Everything that goes into one PDF.
class TicketDocument {
  TicketDocument(List<TicketPage> pages, {this.reference = ''})
      : pages = List<TicketPage>.unmodifiable(pages);

  final List<TicketPage> pages;

  /// Short code identifying this run, e.g. `K7Q2`. Printed on every ticket in
  /// front of its number, so a ticket cut from one batch can never be
  /// confused with the identically numbered ticket from another.
  final String reference;

  /// The identifier printed on the ticket at [index] within the document:
  /// `K7Q2-T014`, numbered straight through from the first page to the last.
  String labelFor(int index) {
    final String number = 'T${(index + 1).toString().padLeft(3, '0')}';
    return reference.isEmpty ? number : '$reference-$number';
  }

  int get pageCount => pages.length;

  int get ticketCount => pages.fold(
      0, (int total, TicketPage page) => total + page.tickets.length);

  int get stripCount => pages.fold(
      0, (int total, TicketPage page) => total + page.strips.length);
}
