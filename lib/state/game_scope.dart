import 'package:flutter/material.dart';

import '../services/game_controller.dart';

/// Makes the single [GameController] available to the whole widget tree and
/// rebuilds every dependent when the game changes. No external state
/// management package needed.
class GameScope extends InheritedNotifier<GameController> {
  const GameScope({
    super.key,
    required GameController controller,
    required super.child,
  }) : super(notifier: controller);

  static GameController of(BuildContext context) {
    final GameScope? scope =
        context.dependOnInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'No GameScope found above this widget.');
    return scope!.notifier!;
  }

  /// Reads the controller without subscribing to changes — for callbacks.
  static GameController read(BuildContext context) {
    final GameScope? scope =
        context.getInheritedWidgetOfExactType<GameScope>();
    assert(scope != null, 'No GameScope found above this widget.');
    return scope!.notifier!;
  }
}
