import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/models/housie_ticket.dart';
import 'package:tambola_caller/services/ticket_generator.dart';
import 'package:tambola_caller/services/ticket_pdf_generator.dart';

void main() {
  group('A4 sheet layout', () {
    final TicketSheetLayout layout = TicketSheetLayout.a4();

    test('is A4 portrait', () {
      expect(layout.pageWidth, closeTo(595.28, 0.1));
      expect(layout.pageHeight, closeTo(841.89, 0.1));
      expect(layout.pageHeight, greaterThan(layout.pageWidth));
    });

    test('twelve tickets fit the printable area', () {
      expect(TicketSheetLayout.ticketsAcross * TicketSheetLayout.ticketsDown,
          HousieRules.ticketsPerPage);
      expect(layout.blockWidth, lessThanOrEqualTo(layout.contentWidth + 0.5));
      expect(layout.blockHeight, lessThanOrEqualTo(layout.contentHeight + 0.5));
    });

    test('keeps the numbers readable and clear of the grid lines', () {
      expect(layout.numberFontSize, greaterThanOrEqualTo(9));
      // Two digits of Helvetica-Bold are about 1.12 em wide.
      expect(layout.numberFontSize * 1.12, lessThan(layout.cellWidth - 2));
      expect(layout.numberFontSize, lessThan(layout.cellHeight));
    });

    test('leaves room to cut between tickets', () {
      expect(layout.columnGap, greaterThanOrEqualTo(8));
      expect(layout.rowGap, greaterThanOrEqualTo(8));
    });

    test('passes its own pre-flight check', () {
      expect(() => TicketSheetLayout.a4().validate(), returnsNormally);
    });
  });

  group('pdf output', () {
    test('builds a one-page A4 document', () async {
      final TicketDocument document =
          TicketGenerator(random: Random(11)).generateDocument(1);
      final Uint8List bytes = await TicketPdfGenerator().build(document);

      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
      expect(bytes.length, greaterThan(1000));
    });

    test('grows with the page count', () async {
      final Uint8List one = await TicketPdfGenerator()
          .build(TicketGenerator(random: Random(12)).generateDocument(1));
      final Uint8List three = await TicketPdfGenerator()
          .build(TicketGenerator(random: Random(13)).generateDocument(3));

      expect(three.length, greaterThan(one.length));
    });

    test('refuses to print an invalid ticket set', () async {
      final TicketDocument broken = TicketDocument(<TicketPage>[
        TicketPage(<TicketStrip>[TicketStrip(const <HousieTicket>[])]),
      ]);

      await expectLater(
        TicketPdfGenerator().build(broken),
        throwsStateError,
      );
    });
  });
}
