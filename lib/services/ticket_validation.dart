import '../models/housie_ticket.dart';

/// Checks generated tickets against every Housie rule.
///
/// Each method returns a list of human-readable problems, empty when the
/// subject is valid. The generator throws away anything that fails, so these
/// are the last word on what may reach a PDF.
abstract final class TicketValidation {
  static bool isValidTicket(HousieTicket ticket) =>
      validateTicket(ticket).isEmpty;

  static bool isValidStrip(TicketStrip strip) => validateStrip(strip).isEmpty;

  static bool isValidPage(TicketPage page) => validatePage(page).isEmpty;

  static bool isValidDocument(TicketDocument document) =>
      validateDocument(document).isEmpty;

  static List<String> validateTicket(HousieTicket ticket) {
    final List<String> problems = <String>[];

    if (ticket.grid.length != HousieRules.rows) {
      problems.add('ticket has ${ticket.grid.length} rows, expected '
          '${HousieRules.rows}');
      return problems;
    }

    for (int row = 0; row < HousieRules.rows; row++) {
      if (ticket.grid[row].length != HousieRules.columns) {
        problems.add('row $row has ${ticket.grid[row].length} cells, expected '
            '${HousieRules.columns}');
        continue;
      }
      final int filled = ticket.numbersInRow(row);
      if (filled != HousieRules.numbersPerRow) {
        problems.add('row $row holds $filled numbers, expected '
            '${HousieRules.numbersPerRow}');
      }
    }

    final List<int> numbers = ticket.numbers;
    if (numbers.length != HousieRules.numbersPerTicket) {
      problems.add('ticket holds ${numbers.length} numbers, expected '
          '${HousieRules.numbersPerTicket}');
    }
    if (numbers.toSet().length != numbers.length) {
      problems.add('ticket repeats a number');
    }
    for (final int number in numbers) {
      if (number < HousieRules.minNumber || number > HousieRules.maxNumber) {
        problems.add('$number is outside ${HousieRules.minNumber}-'
            '${HousieRules.maxNumber}');
      }
    }

    for (int column = 0; column < HousieRules.columns; column++) {
      final List<int> inColumn = ticket.columnNumbers(column);
      if (inColumn.isEmpty) {
        problems.add('column $column is empty');
        continue;
      }
      if (inColumn.length > HousieRules.rows) {
        problems.add('column $column holds ${inColumn.length} numbers');
      }
      for (final int number in inColumn) {
        if (!HousieRules.fitsColumn(number, column)) {
          problems.add('$number does not belong in column $column '
              '(${HousieRules.columnStart[column]}-'
              '${HousieRules.columnEnd[column]})');
        }
      }
      for (int i = 1; i < inColumn.length; i++) {
        if (inColumn[i] <= inColumn[i - 1]) {
          problems.add('column $column is not ascending: $inColumn');
          break;
        }
      }
    }

    return problems;
  }

  static List<String> validateStrip(TicketStrip strip) {
    final List<String> problems = <String>[];

    if (strip.tickets.length != HousieRules.ticketsPerStrip) {
      problems.add('strip holds ${strip.tickets.length} tickets, expected '
          '${HousieRules.ticketsPerStrip}');
    }

    for (int i = 0; i < strip.tickets.length; i++) {
      for (final String problem in validateTicket(strip.tickets[i])) {
        problems.add('ticket ${i + 1}: $problem');
      }
    }

    final List<int> numbers = strip.numbers;
    if (numbers.length != HousieRules.maxNumber) {
      problems.add('strip holds ${numbers.length} numbers, expected '
          '${HousieRules.maxNumber}');
    }
    for (int expected = HousieRules.minNumber;
        expected <= HousieRules.maxNumber;
        expected++) {
      final int count = numbers.where((int n) => n == expected).length;
      if (count != 1) {
        problems.add('$expected appears $count times in the strip');
      }
    }

    return problems;
  }

  static List<String> validatePage(TicketPage page) {
    final List<String> problems = <String>[];

    if (page.strips.length != HousieRules.stripsPerPage) {
      problems.add('page holds ${page.strips.length} strips, expected '
          '${HousieRules.stripsPerPage}');
    }
    if (page.tickets.length != HousieRules.ticketsPerPage) {
      problems.add('page holds ${page.tickets.length} tickets, expected '
          '${HousieRules.ticketsPerPage}');
    }
    for (int i = 0; i < page.strips.length; i++) {
      for (final String problem in validateStrip(page.strips[i])) {
        problems.add('strip ${i + 1}: $problem');
      }
    }

    return problems;
  }

  static List<String> validateDocument(TicketDocument document) {
    final List<String> problems = <String>[];

    if (document.pages.isEmpty) {
      problems.add('document has no pages');
    }
    for (int i = 0; i < document.pages.length; i++) {
      for (final String problem in validatePage(document.pages[i])) {
        problems.add('page ${i + 1}: $problem');
      }
    }

    return problems;
  }
}
