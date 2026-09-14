import 'package:tambola_caller/services/voice_service.dart';

/// Records what would have been spoken, so game logic can be tested without
/// the platform text-to-speech engine.
class FakeVoiceService implements VoiceService {
  FakeVoiceService({this.speakDuration = Duration.zero});

  /// How long [speak] pretends to take. The real engine is configured to
  /// complete only once it has finished speaking, which is what the caller
  /// screen waits on before another number can be drawn.
  final Duration speakDuration;

  final List<String> spoken = <String>[];
  int stopCount = 0;
  double rate = VoiceSpeed.defaultRate;

  @override
  Future<void> speak(String text) async {
    spoken.add(text);
    if (speakDuration > Duration.zero) {
      await Future<void>.delayed(speakDuration);
    }
  }

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<void> setSpeechRate(double value) async => rate = value;

  @override
  Future<void> dispose() async {}
}
