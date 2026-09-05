import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/models/persisted_game.dart';
import 'package:tambola_caller/services/game_controller.dart';
import 'package:tambola_caller/services/game_storage.dart';
import 'package:tambola_caller/services/voice_service.dart';

import 'fakes.dart';

void main() {
  late InMemoryGameStorage storage;
  late FakeVoiceService voice;
  late GameController game;

  setUp(() async {
    storage = InMemoryGameStorage();
    voice = FakeVoiceService();
    game = GameController(
      storage: storage,
      voice: voice,
      random: Random(42),
    );
    await game.load();
  });

  test('starts empty', () {
    expect(game.calledCount, 0);
    expect(game.remainingCount, 90);
    expect(game.currentNumber, isNull);
    expect(game.isComplete, isFalse);
  });

  test('never repeats a number and covers the whole board', () {
    final Set<int> drawn = <int>{};
    for (int i = 0; i < 90; i++) {
      final int? number = game.generate();
      expect(number, isNotNull);
      expect(number! >= 1 && number <= 90, isTrue);
      expect(drawn.add(number), isTrue, reason: '$number was called twice');
    }

    expect(drawn.length, 90);
    expect(game.isComplete, isTrue);
    expect(game.remainingCount, 0);
    expect(game.generate(), isNull, reason: 'the bag is empty');
    expect(game.calledCount, 90);
  });

  test('tracks the current number and recent calls newest first', () {
    final int first = game.generate()!;
    final int second = game.generate()!;
    final int third = game.generate()!;

    expect(game.currentNumber, third);
    expect(game.recentNumbers(count: 2), <int>[third, second]);
    expect(game.calledNumbers, <int>[first, second, third]);
    expect(game.isCalled(first), isTrue);
  });

  test('announces automatically when voice is on', () async {
    final int number = game.generate()!;
    await Future<void>.delayed(Duration.zero);

    expect(voice.spoken, hasLength(1));
    expect(voice.spoken.single.contains('number $number'), isTrue);
  });

  test('stays silent when voice is off', () async {
    await game.setVoiceEnabled(false);
    game.generate();
    await Future<void>.delayed(Duration.zero);

    expect(voice.spoken, isEmpty);
  });

  test('repeat replays the current number without drawing a new one', () async {
    final int number = game.generate()!;
    await Future<void>.delayed(Duration.zero);
    voice.spoken.clear();

    await game.repeat();

    expect(game.currentNumber, number);
    expect(game.calledCount, 1);
    expect(voice.spoken, hasLength(1));
  });

  test('repeat does nothing before the first call', () async {
    await game.repeat();
    expect(voice.spoken, isEmpty);
  });

  test('new game clears the board but keeps settings', () async {
    game.generate();
    await game.setSpeechRate(VoiceSpeed.slow);
    await game.newGame();
    await Future<void>.delayed(Duration.zero);

    expect(game.calledCount, 0);
    expect(game.currentNumber, isNull);
    expect(game.remainingCount, 90);
    expect(game.speechRate, VoiceSpeed.slow);
    expect(storage.current.calledNumbers, isEmpty);
  });

  test('persists the game so it survives a restart', () async {
    final int first = game.generate()!;
    final int second = game.generate()!;
    await Future<void>.delayed(Duration.zero);

    expect(storage.current.calledNumbers, <int>[first, second]);

    final GameController restored = GameController(
      storage: storage,
      voice: FakeVoiceService(),
    );
    await restored.load();

    expect(restored.calledNumbers, <int>[first, second]);
    expect(restored.currentNumber, second);
    expect(restored.calledCount, 2);
  });

  test('speech rate is clamped and pushed to the voice engine', () async {
    await game.setSpeechRate(5);
    expect(game.speechRate, VoiceSpeed.fastest);
    expect(voice.rate, VoiceSpeed.fastest);
  });

  test('welcome screen is only shown once', () async {
    expect(game.hasSeenWelcome, isFalse);
    await game.markWelcomeSeen();
    expect(game.hasSeenWelcome, isTrue);
    expect(storage.current.hasSeenWelcome, isTrue);
  });

  test('restores a saved game and keeps those numbers out of the bag', () async {
    final InMemoryGameStorage saved = InMemoryGameStorage(
      const PersistedGame(calledNumbers: <int>[7, 42]),
    );
    final GameController loaded = GameController(
      storage: saved,
      voice: FakeVoiceService(),
    );
    await loaded.load();

    expect(loaded.calledNumbers, <int>[7, 42]);
    expect(loaded.remainingNumbers.contains(7), isFalse);
    expect(loaded.remainingNumbers.length, 88);
  });
}
