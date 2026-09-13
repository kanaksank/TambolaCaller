import 'package:flutter/material.dart';

import 'app.dart';
import 'services/game_controller.dart';
import 'services/game_storage.dart';
import 'services/orientation_service.dart';
import 'services/voice_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final GameController controller = GameController(
    storage: SharedPreferencesGameStorage(),
    voice: FlutterTtsVoiceService(),
  );
  await controller.load();

  // Apply the caller's saved orientation choice before the first frame so the
  // app never starts in the wrong one and rotates a moment later.
  await applyOrientationMode(controller.orientationMode);

  runApp(TambolaCallerApp(controller: controller));
}
