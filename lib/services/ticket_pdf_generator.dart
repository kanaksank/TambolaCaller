import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/housie_ticket.dart';
import 'ticket_generator.dart';
import 'ticket_validation.dart';

/// Every measurement of the printed sheet, in PDF points (72 to the inch).
///
/// Twelve tickets on A4 are laid out three across and four down. Three across
/// fixes the ticket width, and therefore the cell width and the size the
/// numbers can be printed at; the height is then chosen to fill the page
/// without letting a cell grow absurdly tall.
class TicketSheetLayout {
  TicketSheetLayout._({
    required this.pageWidth,
    required this.pageHeight,
    required this.margin,
    required this.columnGap,
    required this.rowGap,
    required this.footerHeight,
    required this.ticketWidth,
    required this.ticketHeight,
    required this.cellWidth,
    required this.cellHeight,
    required this.labelHeight,
    required this.numberFontSize,
    required this.labelFontSize,
    required this.footerFontSize,
    required this.outerBorder,
    required this.gridLine,
    required this.guideLine,
  });

  factory TicketSheetLayout.a4() {
    const double margin = 22;
    const double columnGap = 12;
    const double rowGap = 26;
    const double footerHeight = 14;
    const double labelHeight = 12;
    const double outerBorder = 1.1;
    const double gridLine = 0.5;
    const double guideLine = 0.4;

    /// A cell may not be more than this many times taller than it is wide.
    const double maxCellAspect = 2.6;

    final double pageWidth = PdfPageFormat.a4.width;
    final double pageHeight = PdfPageFormat.a4.height;
    final double contentWidth = pageWidth - 2 * margin;
    final double contentHeight = pageHeight - 2 * margin - footerHeight;

    final double ticketWidth =
        (contentWidth - columnGap * (ticketsAcross - 1)) / ticketsAcross;
    final double cellWidth = ticketWidth / HousieRules.columns;

    final double heightPerTicket =
        (contentHeight - rowGap * (ticketsDown - 1)) / ticketsDown;
    final double cellHeight = math.min(
      cellWidth * maxCellAspect,
      (heightPerTicket - labelHeight) / HousieRules.rows,
    );
    final double ticketHeight = cellHeight * HousieRules.rows + labelHeight;

    // Two digits of Helvetica-Bold are about 1.12 em wide; leave a little
    // padding so a number never touches a grid line.
    final double numberFontSize = math.min(
      (cellWidth - 4) / 1.15,
      cellHeight * 0.55,
    );

    final TicketSheetLayout layout = TicketSheetLayout._(
      pageWidth: pageWidth,
      pageHeight: pageHeight,
      margin: margin,
      columnGap: columnGap,
      rowGap: rowGap,
      footerHeight: footerHeight,
      ticketWidth: ticketWidth,
      ticketHeight: ticketHeight,
      cellWidth: cellWidth,
      cellHeight: cellHeight,
      labelHeight: labelHeight,
      numberFontSize: numberFontSize,
      labelFontSize: 7,
      footerFontSize: 8,
      outerBorder: outerBorder,
      gridLine: gridLine,
      guideLine: guideLine,
    );
    layout.validate();
    return layout;
  }

  static const int ticketsAcross = 3;
  static const int ticketsDown = 4;

  final double pageWidth;
  final double pageHeight;
  final double margin;
  final double columnGap;
  final double rowGap;
  final double footerHeight;
  final double ticketWidth;
  final double ticketHeight;
  final double cellWidth;
  final double cellHeight;
  final double labelHeight;
  final double numberFontSize;
  final double labelFontSize;
  final double footerFontSize;
  final double outerBorder;
  final double gridLine;
  final double guideLine;

  double get contentWidth => pageWidth - 2 * margin;

  double get contentHeight => pageHeight - 2 * margin - footerHeight;

  double get blockWidth =>
      ticketWidth * ticketsAcross + columnGap * (ticketsAcross - 1);

  double get blockHeight =>
      ticketHeight * ticketsDown + rowGap * (ticketsDown - 1);

  /// Checked before anything is drawn, so a bad measurement can never reach
  /// the printer as clipped or overflowing tickets.
  void validate() {
    if (blockWidth > contentWidth + 0.5) {
      throw StateError('Tickets are ${blockWidth.toStringAsFixed(1)}pt wide '
          'but the printable area is only '
          '${contentWidth.toStringAsFixed(1)}pt.');
    }
    if (blockHeight > contentHeight + 0.5) {
      throw StateError('Tickets are ${blockHeight.toStringAsFixed(1)}pt tall '
          'but the printable area is only '
          '${contentHeight.toStringAsFixed(1)}pt.');
    }
    if (numberFontSize < 8) {
      throw StateError('Numbers would print at '
          '${numberFontSize.toStringAsFixed(1)}pt, too small to read.');
    }
  }

  @override
  String toString() => 'A4 sheet: ticket '
      '${ticketWidth.toStringAsFixed(1)}×${ticketHeight.toStringAsFixed(1)}pt, '
      'cell ${cellWidth.toStringAsFixed(1)}×${cellHeight.toStringAsFixed(1)}pt, '
      'numbers ${numberFontSize.toStringAsFixed(1)}pt';
}

/// Renders a [TicketDocument] as a print-ready A4 PDF.
///
/// Everything is drawn as vector text and lines — no rasterised images — so
/// the numbers stay sharp at any print resolution. Helvetica is one of the
/// fonts every PDF reader already has, which keeps the file small and avoids
/// shipping a font asset.
class TicketPdfGenerator {
  TicketPdfGenerator({TicketSheetLayout? layout})
      : layout = layout ?? TicketSheetLayout.a4();

  final TicketSheetLayout layout;

  Future<Uint8List> build(TicketDocument document) async {
    final List<String> problems = TicketValidation.validateDocument(document);
    if (problems.isNotEmpty) {
      throw StateError('Refusing to print an invalid ticket set: '
          '${problems.first}');
    }

    final pw.Font regular = pw.Font.helvetica();
    final pw.Font bold = pw.Font.helveticaBold();
    final pw.Document pdf = pw.Document(
      title: 'Housie Tickets',
      creator: 'Tambola Caller',
    );

    int ticketNumber = 1;
    for (int index = 0; index < document.pages.length; index++) {
      final TicketPage page = document.pages[index];
      final List<String> labels = <String>[
        for (int i = 0; i < page.tickets.length; i++)
          'T${(ticketNumber + i).toString().padLeft(3, '0')}',
      ];
      ticketNumber += page.tickets.length;

      pdf.addPage(_buildPage(
        page: page,
        labels: labels,
        pageNumber: index + 1,
        pageCount: document.pages.length,
        regular: regular,
        bold: bold,
      ));
    }

    return pdf.save();
  }

  pw.Page _buildPage({
    required TicketPage page,
    required List<String> labels,
    required int pageNumber,
    required int pageCount,
    required pw.Font regular,
    required pw.Font bold,
  }) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: pw.EdgeInsets.all(layout.margin),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: <pw.Widget>[
            pw.Spacer(),
            for (int row = 0; row < TicketSheetLayout.ticketsDown; row++) ...[
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: <pw.Widget>[
                  for (int col = 0;
                      col < TicketSheetLayout.ticketsAcross;
                      col++) ...<pw.Widget>[
                    if (col > 0) _verticalCutGuide(),
                    _ticket(
                      ticket: page.tickets[row * TicketSheetLayout.ticketsAcross + col],
                      label: labels[row * TicketSheetLayout.ticketsAcross + col],
                      regular: regular,
                      bold: bold,
                    ),
                  ],
                ],
              ),
              if (row < TicketSheetLayout.ticketsDown - 1) _horizontalCutGuide(),
            ],
            pw.Spacer(),
            pw.SizedBox(
              height: layout.footerHeight,
              child: pw.Center(
                child: pw.Text(
                  'Page $pageNumber of $pageCount',
                  style: pw.TextStyle(
                    font: regular,
                    fontSize: layout.footerFontSize,
                    color: PdfColors.grey700,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  pw.Widget _ticket({
    required HousieTicket ticket,
    required String label,
    required pw.Font regular,
    required pw.Font bold,
  }) {
    return pw.Container(
      width: layout.ticketWidth,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(
          color: PdfColors.black,
          width: layout.outerBorder,
        ),
      ),
      child: pw.Column(
        mainAxisSize: pw.MainAxisSize.min,
        children: <pw.Widget>[
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColors.black,
              width: layout.gridLine,
            ),
            defaultColumnWidth: pw.FixedColumnWidth(layout.cellWidth),
            children: <pw.TableRow>[
              for (int row = 0; row < HousieRules.rows; row++)
                pw.TableRow(
                  children: <pw.Widget>[
                    for (int col = 0; col < HousieRules.columns; col++)
                      pw.Container(
                        height: layout.cellHeight,
                        alignment: pw.Alignment.center,
                        child: ticket.at(row, col) == null
                            ? pw.SizedBox()
                            : pw.Text(
                                '${ticket.at(row, col)}',
                                style: pw.TextStyle(
                                  font: bold,
                                  fontSize: layout.numberFontSize,
                                  color: PdfColors.black,
                                ),
                              ),
                      ),
                  ],
                ),
            ],
          ),
          pw.Container(
            height: layout.labelHeight,
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(right: 3),
            child: pw.Text(
              label,
              style: pw.TextStyle(
                font: regular,
                fontSize: layout.labelFontSize,
                color: PdfColors.grey700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A hairline down the middle of the gutter, to cut along.
  pw.Widget _verticalCutGuide() => pw.Container(
        width: layout.columnGap,
        height: layout.ticketHeight,
        alignment: pw.Alignment.center,
        child: pw.Container(
          width: layout.guideLine,
          height: layout.ticketHeight,
          color: PdfColors.grey400,
        ),
      );

  pw.Widget _horizontalCutGuide() => pw.Container(
        width: layout.blockWidth,
        height: layout.rowGap,
        alignment: pw.Alignment.center,
        child: pw.Container(
          width: layout.blockWidth,
          height: layout.guideLine,
          color: PdfColors.grey400,
        ),
      );
}

/// Generates and renders a ticket PDF on a background isolate, so a long run
/// of pages never stalls the UI.
Future<Uint8List> generateTicketPdfBytes(int pageCount) =>
    compute(_generateTicketPdf, pageCount);

Future<Uint8List> _generateTicketPdf(int pageCount) async {
  final TicketDocument document = TicketGenerator().generateDocument(pageCount);
  return TicketPdfGenerator().build(document);
}
