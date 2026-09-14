import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/housie_ticket.dart';
import '../services/ticket_generator.dart';
import '../services/ticket_pdf_generator.dart';
import '../theme/app_theme.dart';
import '../widgets/app_header.dart';
import '../widgets/ticket_preview.dart';
import '../widgets/ticket_settings.dart';
import 'ticket_pdf_preview_screen.dart';

/// Generates printable Housie tickets as an A4 PDF.
class TicketsScreen extends StatefulWidget {
  const TicketsScreen({super.key});

  /// Above this the PDF gets large and slow to build on a phone.
  static const int maxPages = 50;

  @override
  State<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends State<TicketsScreen> {
  final TicketGenerator _generator = TicketGenerator();

  late HousieTicket _sample = _generator.generateStrip().tickets.first;
  int _pages = 1;
  bool _busy = false;

  void _newSample() {
    setState(() => _sample = _generator.generateStrip().tickets.first);
  }

  Future<void> _generatePdf() async {
    setState(() => _busy = true);
    try {
      final Uint8List bytes = await generateTicketPdfBytes(_pages);
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => TicketPdfPreviewScreen(
            bytes: bytes,
            pageCount: _pages,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not build the PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          const AppHeader(title: 'HOUSIE TICKETS', shortTitle: 'TICKETS'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      TicketSettings(
                        pages: _pages,
                        maxPages: TicketsScreen.maxPages,
                        enabled: !_busy,
                        onChanged: (int pages) =>
                            setState(() => _pages = pages),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 66,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _generatePdf,
                          icon: _busy
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5),
                                )
                              : const Icon(Icons.picture_as_pdf_rounded,
                                  size: 26),
                          label: Text(
                            _busy ? 'GENERATING…' : 'GENERATE PDF',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        children: <Widget>[
                          Text('SAMPLE TICKET',
                              style: AppTheme.sectionLabel(context)),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _busy ? null : _newSample,
                            icon: const Icon(Icons.casino_rounded, size: 20),
                            label: const Text('Another'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      TicketPreview(ticket: _sample, label: 'T001'),
                      const SizedBox(height: 18),
                      Text(
                        'Every six tickets form a complete strip: between them '
                        'they carry all 90 numbers exactly once, so one strip '
                        'guarantees a full house. Each A4 page holds '
                        '${HousieRules.ticketsPerPage} tickets — two strips — '
                        'with cutting guides between them.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurfaceVariant,
                              height: 1.45,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
