import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Speech rates understood by the text-to-speech engine.
///
/// `flutter_tts` takes a rate between 0.0 and 1.0 on Android, where roughly
/// 0.5 sounds like a normal speaking pace. The default here is deliberately a
/// little slower so a room full of players can follow every digit.
abstract final class VoiceSpeed {
  static const double slowest = 0.25;
  static const double slow = 0.30;
  static const double normal = 0.45;
  static const double fast = 0.62;
  static const double fastest = 0.70;

  /// Slightly slower than normal — the default for a noisy room.
  static const double defaultRate = 0.38;

  static double clamp(double rate) => rate.clamp(slowest, fastest);

  /// Short label shown next to the speed slider.
  static String label(double rate) {
    if (rate <= (slow + normal) / 2) return 'Slow';
    if (rate >= (normal + fast) / 2) return 'Fast';
    return 'Normal';
  }
}

/// Thin abstraction over text-to-speech so the game logic stays testable.
abstract class VoiceService {
  Future<void> speak(String text);

  Future<void> stop();

  Future<void> setSpeechRate(double rate);

  Future<void> dispose();
}

/// Offline, on-device text-to-speech backed by the Android TTS engine.
class FlutterTtsVoiceService implements VoiceService {
  FlutterTtsVoiceService({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;
  double _rate = VoiceSpeed.defaultRate;

  Future<void> _configure() async {
    if (_configured) return;
    _configured = true;
    try {
      // en-IN keeps the number pronunciation familiar for Housie players;
      // fall back to en-US when the device has no Indian English voice.
      final dynamic available = await _tts.isLanguageAvailable('en-IN');
      await _tts.setLanguage(available == true ? 'en-IN' : 'en-US');
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      await _tts.setSpeechRate(_rate);
      await _tts.awaitSpeakCompletion(true);
    } catch (error, stack) {
      debugPrint('Text-to-speech setup failed: $error\n$stack');
    }
  }

  @override
  Future<void> speak(String text) async {
    await _configure();
    try {
      // Flush anything still playing so a fast caller is never queued behind
      // the previous number.
      await _tts.stop();
      await _tts.setSpeechRate(_rate);
      await _tts.speak(text);
    } catch (error) {
      debugPrint('Text-to-speech failed to speak: $error');
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (error) {
      debugPrint('Text-to-speech failed to stop: $error');
    }
  }

  @override
  Future<void> setSpeechRate(double rate) async {
    _rate = VoiceSpeed.clamp(rate);
    if (!_configured) return;
    try {
      await _tts.setSpeechRate(_rate);
    } catch (error) {
      debugPrint('Text-to-speech failed to set rate: $error');
    }
  }

  @override
  Future<void> dispose() => stop();
}
