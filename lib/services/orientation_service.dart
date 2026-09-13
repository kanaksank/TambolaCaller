import 'package:flutter/services.dart';

import '../models/orientation_mode.dart';

/// Translates the caller's preference into the orientations Android allows.
///
/// Kept out of [OrientationMode] itself so the model stays free of Flutter
/// bindings and can be used in plain unit tests.
List<DeviceOrientation> deviceOrientationsFor(OrientationMode mode) {
  switch (mode) {
    case OrientationMode.auto:
      return const <DeviceOrientation>[
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
    case OrientationMode.landscape:
      return const <DeviceOrientation>[
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ];
    case OrientationMode.portrait:
      return const <DeviceOrientation>[DeviceOrientation.portraitUp];
  }
}

Future<void> applyOrientationMode(OrientationMode mode) {
  return SystemChrome.setPreferredOrientations(deviceOrientationsFor(mode));
}
