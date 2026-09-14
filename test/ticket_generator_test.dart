import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/models/housie_ticket.dart';
import 'package:tambola_caller/services/ticket_generator.dart';
import 'package:tambola_caller/services/ticket_validation.dart';

/// Every rule from the Housie ticket specification, asserted directly rather
/// than by trusting the validator the generator itself uses.
void expectValidTicket(HousieTicket ticket) {
  expect(ticket.grid, hasLength(3), reason: 'three rows');

  for (final List<int?> row in ticket.grid) {
    expect(row, hasLength(9), reason: 'nine columns');
  }
  for (int row = 0; row < 3; row++) {
    expect(ticket.numbersInRow(row), 5, reason: 'five numbers in row $row');
  }

  final List<int> numbers = ticket.numbers;
  expect(numbers, hasLength(15), reason: 'fifteen numbers');
  expect(numbers.toSet(), hasLength(15), reason: 'no repeats');
  for (final int number in numbers) {
    expect(number, inInclusiveRange(1, 90));
  }

  for (int column = 0; column < 9; column++) {
    final List<int> inColumn = ticket.columnNumbers(column);
    expect(inColumn, isNotEmpty, reason: 'column $column holds a number');
    expect(inColumn.length, lessThanOrEqualTo(3));
    for (final int number in inColumn) {
      expect(number, greaterThanOrEqualTo(HousieRules.columnStart[column]));
      expect(number, lessThanOrEqualTo(HousieRules.columnEnd[column]));
    }
    final List<int> sorted = List<int>.of(inColumn)..sort();
    expect(inColumn, sorted, reason: 'column $column runs top to bottom');
  }
}

void expectValidStrip(TicketStrip strip) {
  expect(strip.tickets, hasLength(6));
  for (final HousieTicket ticket in strip.tickets) {
    expectValidTicket(ticket);
  }
  expect(
    strip.numbers,
    List<int>.generate(90, (int i) => i + 1),
    reason: 'a strip carries 1-90 exactly once',
  );
}

void main() {
  group('single ticket', () {
    test('follows every ticket rule', () {
      final TicketGenerator generator = TicketGenerator(random: Random(1));
      for (final HousieTicket ticket in generator.generateStrip().tickets) {
        expectValidTicket(ticket);
      }
    });

    test('column counts stay between one and three', () {
      final TicketGenerator generator = TicketGenerator(random: Random(2));
      for (int i = 0; i < 25; i++) {
        for (final HousieTicket ticket in generator.generateStrip().tickets) {
          for (int column = 0; column < 9; column++) {
            expect(ticket.columnNumbers(column).length, inInclusiveRange(1, 3));
          }
        }
      }
    });
  });

  group('six-ticket strip', () {
    test('covers 1-90 exactly once', () {
      final TicketGenerator generator = TicketGenerator(random: Random(3));
      expectValidStrip(generator.generateStrip());
    });

    test('holds up over many strips', () {
      final TicketGenerator generator = TicketGenerator(random: Random(4));
      for (int i = 0; i < 150; i++) {
        final TicketStrip strip = generator.generateStrip();
        expect(TicketValidation.validateStrip(strip), isEmpty,
            reason: 'strip $i');
        expect(strip.numbers, List<int>.generate(90, (int n) => n + 1));
      }
    });

    test('produces a different strip each time', () {
      final TicketGenerator generator = TicketGenerator(random: Random(5));
      final Set<String> seen = <String>{};
      for (int i = 0; i < 20; i++) {
        seen.add(generator
            .generateStrip()
            .tickets
            .map((HousieTicket t) => t.grid.toString())
            .join('|'));
      }
      expect(seen, hasLength(20), reason: 'no two strips were identical');
    });
  });

  group('page', () {
    test('is twelve tickets in two independent strips', () {
      final TicketGenerator generator = TicketGenerator(random: Random(6));
      final TicketPage page = generator.generatePage();

      expect(page.strips, hasLength(2));
      expect(page.tickets, hasLength(12));
      for (final TicketStrip strip in page.strips) {
        expectValidStrip(strip);
      }
      expect(TicketValidation.validatePage(page), isEmpty);
    });
  });

  group('document', () {
    for (final int pages in <int>[1, 2, 10, 50]) {
      test('$pages ${pages == 1 ? 'page' : 'pages'} of valid tickets', () {
        final TicketGenerator generator = TicketGenerator(random: Random(pages));
        final TicketDocument document = generator.generateDocument(pages);

        expect(document.pageCount, pages);
        expect(document.ticketCount, pages * 12);
        expect(document.stripCount, pages * 2);
        expect(TicketValidation.validateDocument(document), isEmpty);

        for (final TicketPage page in document.pages) {
          expect(page.tickets, hasLength(12));
          for (final TicketStrip strip in page.strips) {
            expect(strip.numbers, List<int>.generate(90, (int n) => n + 1));
          }
        }
      });
    }

    test('numbers every ticket uniquely, straight through the document', () {
      final TicketGenerator generator = TicketGenerator(random: Random(9));
      final TicketDocument document = generator.generateDocument(4);

      final List<String> labels = <String>[
        for (int i = 0; i < document.ticketCount; i++) document.labelFor(i),
      ];

      expect(labels, hasLength(48));
      expect(labels.toSet(), hasLength(48), reason: 'no repeated identifier');
      expect(labels.first, endsWith('T001'));
      expect(labels[12], endsWith('T013'),
          reason: 'numbering carries on across the page break');
      expect(labels.last, endsWith('T048'));
    });

    test('each run carries its own set reference', () {
      final TicketGenerator generator = TicketGenerator(random: Random(10));
      final Set<String> references = <String>{
        for (int i = 0; i < 12; i++)
          generator.generateDocument(1).reference,
      };

      expect(references.length, greaterThan(8),
          reason: 'references should differ between runs');
      for (final String reference in references) {
        expect(reference, hasLength(4));
        expect(RegExp(r'^[A-Z2-9]{4}$').hasMatch(reference), isTrue);
      }
    });

    test('rejects a page count below one', () {
      final TicketGenerator generator = TicketGenerator(random: Random(7));
      expect(() => generator.generateDocument(0), throwsArgumentError);
      expect(() => generator.generateDocument(-3), throwsArgumentError);
    });
  });

  group('validation catches broken tickets', () {
    HousieTicket ticketFrom(List<List<int?>> grid) => HousieTicket(grid);

    List<List<int?>> blankGrid() => List<List<int?>>.generate(
        3, (_) => List<int?>.filled(9, null));

    test('flags a row with the wrong count', () {
      final List<List<int?>> grid = blankGrid();
      // Six numbers in the first row, four in the second.
      const List<int> firstRow = <int>[1, 11, 21, 31, 41, 51];
      for (int i = 0; i < firstRow.length; i++) {
        grid[0][i] = firstRow[i];
      }
      const List<int> secondRow = <int>[2, 12, 22, 32];
      for (int i = 0; i < secondRow.length; i++) {
        grid[1][i] = secondRow[i];
      }
      for (int i = 0; i < 5; i++) {
        grid[2][i + 4] = <int>[43, 53, 63, 73, 83][i];
      }

      final List<String> problems =
          TicketValidation.validateTicket(ticketFrom(grid));
      expect(problems, isNotEmpty);
      expect(problems.any((String p) => p.contains('row 0')), isTrue);
    });

    test('flags a number in the wrong column', () {
      final List<List<int?>> grid = blankGrid();
      for (int column = 0; column < 9; column++) {
        grid[0][column] = HousieRules.columnStart[column];
      }
      grid[0][3] = 88; // belongs in the last column
      final List<String> problems =
          TicketValidation.validateTicket(ticketFrom(grid));
      expect(problems.any((String p) => p.contains('does not belong')), isTrue);
    });

    test('flags a column that runs out of order', () {
      final List<List<int?>> grid = blankGrid();
      grid[0][0] = 7;
      grid[1][0] = 3;
      final List<String> problems =
          TicketValidation.validateTicket(ticketFrom(grid));
      expect(problems.any((String p) => p.contains('ascending')), isTrue);
    });

    test('flags a strip that does not cover 1-90', () {
      final TicketGenerator generator = TicketGenerator(random: Random(8));
      final TicketStrip strip = generator.generateStrip();
      final TicketStrip broken = TicketStrip(<HousieTicket>[
        ...strip.tickets.take(5),
        strip.tickets.first, // duplicate ticket, so numbers repeat
      ]);
      expect(TicketValidation.validateStrip(broken), isNotEmpty);
    });
  });
}
