import '../services/voice_service.dart';
import 'orientation_mode.dart';

/// The snapshot written to disk so a game survives the app being closed.
class PersistedGame {
  const PersistedGame({
    this.calledNumbers = const <int>[],
    this.voiceEnabled = true,
    this.speechRate = VoiceSpeed.defaultRate,
    this.hasSeenWelcome = false,
    this.orientationMode = OrientationMode.auto,
  });

  /// Called numbers in the order they were called; the last one is current.
  final List<int> calledNumbers;
  final bool voiceEnabled;
  final double speechRate;
  final bool hasSeenWelcome;
  final OrientationMode orientationMode;

  PersistedGame copyWith({
    List<int>? calledNumbers,
    bool? voiceEnabled,
    double? speechRate,
    bool? hasSeenWelcome,
    OrientationMode? orientationMode,
  }) {
    return PersistedGame(
      calledNumbers: calledNumbers ?? this.calledNumbers,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechRate: speechRate ?? this.speechRate,
      hasSeenWelcome: hasSeenWelcome ?? this.hasSeenWelcome,
      orientationMode: orientationMode ?? this.orientationMode,
    );
  }
}
