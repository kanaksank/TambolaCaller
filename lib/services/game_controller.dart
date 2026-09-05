import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/announcement.dart';
import '../models/persisted_game.dart';
import 'announcement_builder.dart';
import 'game_storage.dart';
import 'voice_service.dart';

/// All Tambola game rules live here — the UI only reads and reacts.
///
/// Guarantees:
///   * numbers are only ever drawn from 1-90;
///   * a number is never drawn twice in the same game;
///   * the called list, the current number and the voice settings survive the
///     app being closed;
///   * everything works with no network connection.
class GameController extends ChangeNotifier {
  GameController({
    required GameStorage storage,
    required VoiceService voice,
    Random? random,
  })  : _storage = storage,
        _voice = voice,
        _random = random ?? Random();

  static const int totalNumbers = AnnouncementBuilder.maxNumber;

  final GameStorage _storage;
  final VoiceService _voice;
  final Random _random;

  final List<int> _called = <int>[];
  final Set<int> _calledSet = <int>{};

  bool _voiceEnabled = true;
  double _speechRate = VoiceSpeed.defaultRate;
  bool _hasSeenWelcome = false;
  bool _isLoaded = false;

  // ---------------------------------------------------------------- getters

  bool get isLoaded => _isLoaded;

  /// Called numbers, oldest first.
  List<int> get calledNumbers => List<int>.unmodifiable(_called);

  /// Numbers still in the bag, ascending.
  List<int> get remainingNumbers => <int>[
        for (int n = AnnouncementBuilder.minNumber; n <= totalNumbers; n++)
          if (!_calledSet.contains(n)) n,
      ];

  /// Most recent calls, newest first.
  List<int> recentNumbers({int count = 8}) =>
      _called.reversed.take(count).toList(growable: false);

  int? get currentNumber => _called.isEmpty ? null : _called.last;

  Announcement? get currentAnnouncement {
    final number = currentNumber;
    return number == null ? null : AnnouncementBuilder.build(number);
  }

  int get calledCount => _called.length;

  int get remainingCount => totalNumbers - _called.length;

  bool get isComplete => _called.length >= totalNumbers;

  bool get hasStarted => _called.isNotEmpty;

  bool get voiceEnabled => _voiceEnabled;

  double get speechRate => _speechRate;

  bool get hasSeenWelcome => _hasSeenWelcome;

  bool isCalled(int number) => _calledSet.contains(number);

  // ---------------------------------------------------------------- actions

  /// Restores the saved game. Call once, before the first frame.
  Future<void> load() async {
    final saved = await _storage.load();
    _called
      ..clear()
      ..addAll(saved.calledNumbers);
    _calledSet
      ..clear()
      ..addAll(saved.calledNumbers);
    _voiceEnabled = saved.voiceEnabled;
    _speechRate = VoiceSpeed.clamp(saved.speechRate);
    _hasSeenWelcome = saved.hasSeenWelcome;
    _isLoaded = true;
    await _voice.setSpeechRate(_speechRate);
    notifyListeners();
  }

  /// Draws a fresh number, marks it called and announces it.
  ///
  /// Returns the new number, or `null` when all 90 have already been called.
  int? generate() {
    if (isComplete) return null;

    final available = remainingNumbers;
    final number = available[_random.nextInt(available.length)];
    _called.add(number);
    _calledSet.add(number);
    notifyListeners();

    unawaited(_announce(number));
    unawaited(_persist());
    return number;
  }

  /// Repeats the current announcement without drawing a new number.
  Future<void> repeat() async {
    final number = currentNumber;
    if (number == null) return;
    await _announce(number);
  }

  /// Clears every called number and starts over. Settings are kept.
  Future<void> newGame() async {
    await _voice.stop();
    _called.clear();
    _calledSet.clear();
    notifyListeners();
    await _persist();
  }

  Future<void> setVoiceEnabled(bool enabled) async {
    if (_voiceEnabled == enabled) return;
    _voiceEnabled = enabled;
    if (!enabled) await _voice.stop();
    notifyListeners();
    await _persist();
  }

  Future<void> setSpeechRate(double rate) async {
    final clamped = VoiceSpeed.clamp(rate);
    if (_speechRate == clamped) return;
    _speechRate = clamped;
    notifyListeners();
    await _voice.setSpeechRate(clamped);
    await _persist();
  }

  /// Speaks a sample line so the caller can judge the speed.
  Future<void> previewVoice() async {
    if (!_voiceEnabled) return;
    await _voice.speak(AnnouncementBuilder.build(67).speech);
  }

  Future<void> markWelcomeSeen() async {
    if (_hasSeenWelcome) return;
    _hasSeenWelcome = true;
    notifyListeners();
    await _persist();
  }

  Future<void> stopSpeaking() => _voice.stop();

  // --------------------------------------------------------------- internals

  Future<void> _announce(int number) async {
    if (!_voiceEnabled) return;
    await _voice.speak(AnnouncementBuilder.build(number).speech);
  }

  Future<void> _persist() {
    return _storage.save(
      PersistedGame(
        calledNumbers: List<int>.unmodifiable(_called),
        voiceEnabled: _voiceEnabled,
        speechRate: _speechRate,
        hasSeenWelcome: _hasSeenWelcome,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_voice.dispose());
    super.dispose();
  }
}
