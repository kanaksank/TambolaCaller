import 'dart:math';

import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/app.dart';
import 'package:tambola_caller/models/persisted_game.dart';
import 'package:tambola_caller/services/game_controller.dart';
import 'package:tambola_caller/services/game_storage.dart';

import 'fakes.dart';

Future<GameController> _pumpApp(
  WidgetTester tester, {
  PersistedGame saved = const PersistedGame(hasSeenWelcome: true),
}) async {
  final GameController controller = GameController(
    storage: InMemoryGameStorage(saved),
    voice: FakeVoiceService(),
    random: Random(7),
  );
  await controller.load();
  await tester.pumpWidget(TambolaCallerApp(controller: controller));
  await tester.pumpAndSettle();
  return controller;
}

void main() {
  testWidgets('welcome screen leads into the caller', (WidgetTester tester) async {
    final GameController controller =
        await _pumpApp(tester, saved: const PersistedGame());

    expect(find.text('START GAME'), findsOneWidget);

    await tester.tap(find.text('START GAME'));
    await tester.pumpAndSettle();

    expect(controller.hasSeenWelcome, isTrue);
    expect(find.text('TAMBOLA CALLER'), findsOneWidget);
  });

  testWidgets('generating a number updates the display',
      (WidgetTester tester) async {
    final GameController controller = await _pumpApp(tester);

    // The counter appears in both tab headers, hence findsWidgets.
    expect(find.text('0 / 90'), findsWidgets);

    await tester.tap(find.text('GENERATE NUMBER'));
    await tester.pumpAndSettle();

    final int? number = controller.currentNumber;
    expect(number, isNotNull);
    expect(controller.calledCount, 1);
    expect(find.text('NUMBER $number'), findsOneWidget);
    expect(find.text('1 / 90'), findsWidgets);
  });

  testWidgets('the number board marks called numbers',
      (WidgetTester tester) async {
    final GameController controller = await _pumpApp(
      tester,
      saved: const PersistedGame(
        hasSeenWelcome: true,
        calledNumbers: <int>[12, 45],
      ),
    );

    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Current'), findsOneWidget);
    expect(controller.isCalled(12), isTrue);
    expect(find.text('REMAINING 88'), findsOneWidget);
  });
}
