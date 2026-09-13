import 'package:flutter/material.dart';

import '../services/game_controller.dart';
import '../state/game_scope.dart';
import '../theme/app_theme.dart';
import '../widgets/action_buttons.dart';
import '../widgets/announcement_text.dart';
import '../widgets/app_header.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/game_complete_card.dart';
import '../widgets/number_ball.dart';
import '../widgets/recent_numbers.dart';

/// The primary screen: one very large number, one very large button.
class CallerScreen extends StatelessWidget {
  const CallerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);

    return SafeArea(
      bottom: false,
      child: Column(
        children: <Widget>[
          const AppHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  if (game.isComplete) {
                    return GameCompleteCard(
                      onNewGame: () => _startNewGame(context, game),
                    );
                  }
                  final bool isLandscape =
                      constraints.maxWidth > constraints.maxHeight;
                  return isLandscape
                      ? _LandscapeCaller(game: game)
                      : _PortraitCaller(game: game);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> _startNewGame(
    BuildContext context,
    GameController game,
  ) async {
    final bool confirmed = await confirmNewGame(context);
    if (confirmed) await game.newGame();
  }
}

class _PortraitCaller extends StatelessWidget {
  const _PortraitCaller({required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(child: NumberBall(number: game.currentNumber)),
        const SizedBox(height: 14),
        AnnouncementText(announcement: game.currentAnnouncement),
        const SizedBox(height: 18),
        GenerateButton(onPressed: game.isComplete ? null : game.generate),
        const SizedBox(height: 10),
        RepeatButton(
          onPressed: game.currentNumber == null || !game.voiceEnabled
              ? null
              : () => game.repeat(),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 92,
          child: Align(
            alignment: Alignment.topLeft,
            child: RecentNumbers(
              numbers: game.recentNumbers(),
              horizontal: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _LandscapeCaller extends StatelessWidget {
  const _LandscapeCaller({required this.game});

  final GameController game;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;

    // Left: nothing but the number, so it gets the full height of the screen.
    // Right: the controls, with the recent calls directly beneath them.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Column(
            children: <Widget>[
              Expanded(child: NumberBall(number: game.currentNumber)),
              const SizedBox(height: 10),
              AnnouncementText(
                announcement: game.currentAnnouncement,
                compact: true,
              ),
            ],
          ),
        ),
        const SizedBox(width: 18),
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              GenerateButton(
                height: 66,
                onPressed: game.isComplete ? null : game.generate,
              ),
              const SizedBox(height: 10),
              RepeatButton(
                height: 52,
                onPressed: game.currentNumber == null || !game.voiceEnabled
                    ? null
                    : () => game.repeat(),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RecentNumbers(
                          numbers: game.recentNumbers(count: 9),
                          compact: true,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: <Widget>[
                            Text(
                              'REMAINING',
                              style: AppTheme.sectionLabel(context),
                            ),
                            const Spacer(),
                            Text(
                              '${game.remainingCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: scheme.primary,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
