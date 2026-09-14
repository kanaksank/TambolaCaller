import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:tambola_caller/models/orientation_mode.dart';
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
      settleDelay: Duration.zero,
    );
    await game.load();
  });

  test('starts empty', () {
    expect(game.calledCount, 0);
    expect(game.remainingCount, 90);
    expect(game.currentNumber, isNull);
    expect(game.isComplete, isFalse);
  });

  test('never repeats a number and covers the whole board', () async {
    final Set<int> drawn = <int>{};
    for (int i = 0; i < 90; i++) {
      final int? number = game.generate();
      await pumpEventQueue();
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

  test('tracks the current number and recent calls newest first', () async {
    final int first = game.generate()!;
    await pumpEventQueue();
    final int second = game.generate()!;
    await pumpEventQueue();
    final int third = game.generate()!;
    await pumpEventQueue();

    expect(game.currentNumber, third);
    expect(game.recentNumbers(count: 2), <int>[third, second]);
    expect(game.calledNumbers, <int>[first, second, third]);
    expect(game.isCalled(first), isTrue);
  });

  test('announces automatically when voice is on', () async {
    final int number = game.generate()!;
    await pumpEventQueue();

    expect(voice.spoken, hasLength(1));
    expect(voice.spoken.single.contains('number $number'), isTrue);
  });

  test('stays silent when voice is off', () async {
    await game.setVoiceEnabled(false);
    game.generate();
    await pumpEventQueue();

    expect(voice.spoken, isEmpty);
  });

  test('repeat replays the current number without drawing a new one', () async {
    final int number = game.generate()!;
    await pumpEventQueue();
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
    await pumpEventQueue();

    expect(game.calledCount, 0);
    expect(game.currentNumber, isNull);
    expect(game.remainingCount, 90);
    expect(game.speechRate, VoiceSpeed.slow);
    expect(storage.current.calledNumbers, isEmpty);
  });

  test('persists the game so it survives a restart', () async {
    final int first = game.generate()!;
    await pumpEventQueue();
    final int second = game.generate()!;
    await pumpEventQueue();

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

  group('one call at a time', () {
    GameController controllerWith({
      Duration speakDuration = Duration.zero,
      Duration settleDelay = Duration.zero,
      int seed = 3,
    }) {
      return GameController(
        storage: InMemoryGameStorage(),
        voice: FakeVoiceService(speakDuration: speakDuration),
        random: Random(seed),
        settleDelay: settleDelay,
      );
    }

    test('a tap during the announcement draws nothing at all', () async {
      final GameController controller =
          controllerWith(speakDuration: const Duration(milliseconds: 60));
      await controller.load();

      expect(controller.generate(), isNotNull);
      expect(controller.isAnnouncing, isTrue);
      expect(controller.generate(), isNull, reason: 'still being spoken');
      expect(controller.generate(), isNull);
      expect(controller.calledCount, 1, reason: 'the extra taps drew nothing');

      await Future<void>.delayed(const Duration(milliseconds: 130));

      expect(controller.isAnnouncing, isFalse);
      expect(controller.generate(), isNotNull);
      expect(controller.calledCount, 2);
    });

    test('the pause after the announcement also swallows taps', () async {
      final GameController controller =
          controllerWith(settleDelay: const Duration(milliseconds: 80), seed: 4);
      await controller.load();

      controller.generate();
      await pumpEventQueue();

      expect(controller.isAnnouncing, isTrue,
          reason: 'speaking is done but the pause is still running');
      expect(controller.generate(), isNull);
      expect(controller.calledCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 150));

      expect(controller.isAnnouncing, isFalse);
      expect(controller.generate(), isNotNull);
    });

    test('holds the line with the voice switched off too', () async {
      final GameController controller =
          controllerWith(settleDelay: const Duration(milliseconds: 60), seed: 5);
      await controller.load();
      await controller.setVoiceEnabled(false);

      controller.generate();
      expect(controller.generate(), isNull);
      expect(controller.calledCount, 1);

      await Future<void>.delayed(const Duration(milliseconds: 120));

      expect(controller.generate(), isNotNull);
      expect(controller.calledCount, 2);
    });

    test('repeat cannot cut into the call it would repeat', () async {
      final FakeVoiceService voice =
          FakeVoiceService(speakDuration: const Duration(milliseconds: 60));
      final GameController controller = GameController(
        storage: InMemoryGameStorage(),
        voice: voice,
        random: Random(6),
        settleDelay: Duration.zero,
      );
      await controller.load();

      controller.generate();
      await controller.repeat();

      expect(voice.spoken, hasLength(1), reason: 'the repeat was ignored');

      await Future<void>.delayed(const Duration(milliseconds: 130));
      await controller.repeat();

      expect(voice.spoken, hasLength(2));
    });

    test('a new game reopens the button at once', () async {
      final GameController controller = controllerWith(
        speakDuration: const Duration(milliseconds: 40),
        settleDelay: const Duration(milliseconds: 300),
        seed: 7,
      );
      await controller.load();

      controller.generate();
      expect(controller.isAnnouncing, isTrue);

      await controller.newGame();

      expect(controller.isAnnouncing, isFalse);
      expect(controller.generate(), isNotNull);
    });
  });

  test('speech rate is clamped and pushed to the voice engine', () async {
    await game.setSpeechRate(5);
    expect(game.speechRate, VoiceSpeed.fastest);
    expect(voice.rate, VoiceSpeed.fastest);
  });

  test('remembers the orientation preference', () async {
    expect(game.orientationMode, OrientationMode.auto);

    await game.setOrientationMode(OrientationMode.portrait);

    expect(game.orientationMode, OrientationMode.portrait);
    expect(storage.current.orientationMode, OrientationMode.portrait);
    expect(
      OrientationMode.fromStorage(
        storage.current.orientationMode.storageKey,
      ),
      OrientationMode.portrait,
    );
  });

  test('falls back to auto for an unknown stored orientation', () {
    expect(OrientationMode.fromStorage('sideways'), OrientationMode.auto);
    expect(OrientationMode.fromStorage(null), OrientationMode.auto);
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
