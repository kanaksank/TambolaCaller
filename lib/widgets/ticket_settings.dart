import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/housie_ticket.dart';
import '../theme/app_theme.dart';

/// How many A4 pages to print, with the resulting ticket count spelled out.
class TicketSettings extends StatefulWidget {
  const TicketSettings({
    super.key,
    required this.pages,
    required this.maxPages,
    required this.onChanged,
    this.enabled = true,
  });

  final int pages;
  final int maxPages;
  final ValueChanged<int> onChanged;
  final bool enabled;

  static const List<int> quickChoices = <int>[1, 2, 5, 10];

  @override
  State<TicketSettings> createState() => _TicketSettingsState();
}

class _TicketSettingsState extends State<TicketSettings> {
  late final TextEditingController _controller =
      TextEditingController(text: '${widget.pages}');
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant TicketSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pages != oldWidget.pages &&
        _controller.text != '${widget.pages}') {
      _controller.text = '${widget.pages}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  int _clamp(int value) {
    if (value < 1) return 1;
    if (value > widget.maxPages) return widget.maxPages;
    return value;
  }

  void _submit(String raw) {
    final int? parsed = int.tryParse(raw.trim());
    final int next = parsed == null ? widget.pages : _clamp(parsed);
    _controller.text = '$next';
    widget.onChanged(next);
  }

  void _step(int delta) {
    final int next = _clamp(widget.pages + delta);
    _controller.text = '$next';
    _focusNode.unfocus();
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    final int tickets = widget.pages * HousieRules.ticketsPerPage;
    final int strips = widget.pages * HousieRules.stripsPerPage;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('NUMBER OF A4 PAGES', style: AppTheme.sectionLabel(context)),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              IconButton.filledTonal(
                onPressed:
                    widget.enabled && widget.pages > 1 ? () => _step(-1) : null,
                icon: const Icon(Icons.remove_rounded),
                tooltip: 'One page fewer',
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: widget.enabled,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    helperText: '1 to ${widget.maxPages}',
                    helperStyle: Theme.of(context).textTheme.bodySmall,
                  ),
                  onSubmitted: _submit,
                  onTapOutside: (PointerDownEvent event) {
                    _focusNode.unfocus();
                    _submit(_controller.text);
                  },
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filledTonal(
                onPressed: widget.enabled && widget.pages < widget.maxPages
                    ? () => _step(1)
                    : null,
                icon: const Icon(Icons.add_rounded),
                tooltip: 'One page more',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              for (final int choice in TicketSettings.quickChoices)
                ChoiceChip(
                  label: Text('$choice'),
                  selected: widget.pages == choice,
                  onSelected: widget.enabled
                      ? (bool _) {
                          _controller.text = '$choice';
                          _focusNode.unfocus();
                          widget.onChanged(choice);
                        }
                      : null,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            '$tickets tickets · $strips six-ticket strips · '
            '${HousieRules.ticketsPerPage} per page',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}
