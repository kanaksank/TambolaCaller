/// How the caller wants the app to sit on screen.
///
/// Landscape shows the number at its biggest, but a caller holding the phone
/// one-handed may prefer portrait, so the choice is theirs and it is
/// remembered between sessions.
enum OrientationMode {
  /// Follow the device — rotate freely between portrait and landscape.
  auto('auto', 'Auto'),

  /// Stay in landscape whichever way the device is turned.
  landscape('landscape', 'Landscape'),

  /// Stay upright in portrait.
  portrait('portrait', 'Portrait');

  const OrientationMode(this.storageKey, this.label);

  /// Stable value written to local storage; never change these strings.
  final String storageKey;

  /// Short label shown in the game controls.
  final String label;

  static OrientationMode fromStorage(String? value) {
    for (final OrientationMode mode in values) {
      if (mode.storageKey == value) return mode;
    }
    return OrientationMode.auto;
  }
}
