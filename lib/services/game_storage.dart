import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/persisted_game.dart';
import 'announcement_builder.dart';

/// Local, offline persistence for the running game. No network, no account.
abstract class GameStorage {
  Future<PersistedGame> load();

  Future<void> save(PersistedGame game);
}

class SharedPreferencesGameStorage implements GameStorage {
  static const String _calledKey = 'tambola.called_numbers';
  static const String _voiceKey = 'tambola.voice_enabled';
  static const String _rateKey = 'tambola.speech_rate';
  static const String _welcomeKey = 'tambola.has_seen_welcome';

  @override
  Future<PersistedGame> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getStringList(_calledKey) ?? const <String>[];

      final seen = <int>{};
      final called = <int>[];
      for (final raw in stored) {
        final value = int.tryParse(raw);
        if (value == null) continue;
        if (value < AnnouncementBuilder.minNumber ||
            value > AnnouncementBuilder.maxNumber) {
          continue;
        }
        if (seen.add(value)) called.add(value);
      }

      return PersistedGame(
        calledNumbers: called,
        voiceEnabled: prefs.getBool(_voiceKey) ?? true,
        speechRate: prefs.getDouble(_rateKey) ?? const PersistedGame().speechRate,
        hasSeenWelcome: prefs.getBool(_welcomeKey) ?? false,
      );
    } catch (error) {
      debugPrint('Could not read the saved game: $error');
      return const PersistedGame();
    }
  }

  @override
  Future<void> save(PersistedGame game) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _calledKey,
        game.calledNumbers.map((number) => number.toString()).toList(),
      );
      await prefs.setBool(_voiceKey, game.voiceEnabled);
      await prefs.setDouble(_rateKey, game.speechRate);
      await prefs.setBool(_welcomeKey, game.hasSeenWelcome);
    } catch (error) {
      debugPrint('Could not save the game: $error');
    }
  }
}

/// In-memory storage used by tests.
class InMemoryGameStorage implements GameStorage {
  InMemoryGameStorage([this._game = const PersistedGame()]);

  PersistedGame _game;

  PersistedGame get current => _game;

  @override
  Future<PersistedGame> load() async => _game;

  @override
  Future<void> save(PersistedGame game) async => _game = game;
}
