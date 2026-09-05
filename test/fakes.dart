import 'package:tambola_caller/services/voice_service.dart';

/// Records what would have been spoken, so game logic can be tested without
/// the platform text-to-speech engine.
class FakeVoiceService implements VoiceService {
  final List<String> spoken = <String>[];
  int stopCount = 0;
  double rate = VoiceSpeed.defaultRate;

  @override
  Future<void> speak(String text) async => spoken.add(text);

  @override
  Future<void> stop() async => stopCount++;

  @override
  Future<void> setSpeechRate(double value) async => rate = value;

  @override
  Future<void> dispose() async {}
}
