import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/housie_ticket.dart';

/// Preview, print, share or save the generated ticket PDF.
class TicketPdfPreviewScreen extends StatelessWidget {
  const TicketPdfPreviewScreen({
    super.key,
    required this.bytes,
    required this.pageCount,
  });

  final Uint8List bytes;
  final int pageCount;

  String get _fileName => 'housie-tickets-${pageCount}p.pdf';

  @override
  Widget build(BuildContext context) {
    final int tickets = pageCount * HousieRules.ticketsPerPage;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'HOUSIE TICKETS',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '$pageCount ${pageCount == 1 ? 'page' : 'pages'} · $tickets tickets',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            tooltip: 'Share or open',
            onPressed: () =>
                Printing.sharePdf(bytes: bytes, filename: _fileName),
            icon: const Icon(Icons.ios_share_rounded),
          ),
        ],
      ),
      body: PdfPreview(
        build: (PdfPageFormat format) => bytes,
        pdfFileName: _fileName,
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        allowPrinting: true,
        allowSharing: true,
        padding: const EdgeInsets.all(8),
      ),
    );
  }
}
