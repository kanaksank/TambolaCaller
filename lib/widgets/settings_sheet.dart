import 'package:flutter/material.dart';

import '../services/game_controller.dart';
import '../services/voice_service.dart';
import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import 'confirm_dialog.dart';

/// Game controls: voice, speed, reset and new game.
Future<void> showGameSettings(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) => const _GameSettingsSheet(),
  );
}

class _GameSettingsSheet extends StatelessWidget {
  const _GameSettingsSheet();

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text('GAME CONTROLS', style: AppTheme.sectionLabel(context)),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                _Stat(
                  label: 'Called',
                  value: '${game.calledCount} / ${GameController.totalNumbers}',
                ),
                const SizedBox(width: 12),
                _Stat(label: 'Remaining', value: '${game.remainingCount}'),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: game.voiceEnabled,
              onChanged: (bool value) => game.setVoiceEnabled(value),
              secondary: Icon(
                game.voiceEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
              ),
              title: Text(game.voiceEnabled ? 'Voice ON' : 'Voice OFF'),
              subtitle: const Text('Announce every number out loud'),
            ),
            const Divider(height: 24),
            Row(
              children: <Widget>[
                const Icon(Icons.speed_rounded),
                const SizedBox(width: 12),
                Text(
                  'Voice speed',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Text(
                  VoiceSpeed.label(game.speechRate),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                ),
              ],
            ),
            Slider(
              value: game.speechRate,
              min: VoiceSpeed.slowest,
              max: VoiceSpeed.fastest,
              divisions: 9,
              label: VoiceSpeed.label(game.speechRate),
              onChanged: game.voiceEnabled
                  ? (double value) => game.setSpeechRate(value)
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text('Slow', style: Theme.of(context).textTheme.bodySmall),
                  Text('Normal', style: Theme.of(context).textTheme.bodySmall),
                  Text('Fast', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: game.voiceEnabled ? () => game.previewVoice() : null,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Test voice'),
              ),
            ),
            const Divider(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.restart_alt_rounded),
              title: const Text('New game'),
              subtitle: const Text('Clear every called number and start fresh'),
              onTap: () => _clearGame(context, game, isReset: false),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.undo_rounded),
              title: const Text('Reset current game'),
              subtitle: const Text('Put all 90 numbers back in the bag'),
              enabled: game.hasStarted,
              onTap: game.hasStarted
                  ? () => _clearGame(context, game, isReset: true)
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              'Works completely offline — no internet, no account, no server.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearGame(
    BuildContext context,
    GameController game, {
    required bool isReset,
  }) async {
    final NavigatorState navigator = Navigator.of(context);
    final bool confirmed = await confirmNewGame(context, isReset: isReset);
    if (!confirmed) return;
    await game.newGame();
    if (navigator.canPop()) navigator.pop();
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label.toUpperCase(), style: AppTheme.sectionLabel(context)),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
