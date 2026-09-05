import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'services/game_controller.dart';
import 'services/game_storage.dart';
import 'services/voice_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Landscape is the preferred way to run a game, but the caller may hold the
  // phone either way, so every orientation stays available.
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);

  final GameController controller = GameController(
    storage: SharedPreferencesGameStorage(),
    voice: FlutterTtsVoiceService(),
  );
  await controller.load();

  runApp(TambolaCallerApp(controller: controller));
}
