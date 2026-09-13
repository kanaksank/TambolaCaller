import 'dart:async';

import 'package:flutter/material.dart';

import 'models/orientation_mode.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/game_controller.dart';
import 'services/orientation_service.dart';
import 'state/game_scope.dart';
import 'theme/app_theme.dart';

class TambolaCallerApp extends StatelessWidget {
  const TambolaCallerApp({super.key, required this.controller});

  final GameController controller;

  @override
  Widget build(BuildContext context) {
    return GameScope(
      controller: controller,
      child: MaterialApp(
        title: 'Tambola Caller',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: const _OrientationLock(child: _RootScreen()),
      ),
    );
  }
}

/// Keeps the device orientation in step with the caller's saved preference.
class _OrientationLock extends StatefulWidget {
  const _OrientationLock({required this.child});

  final Widget child;

  @override
  State<_OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<_OrientationLock> {
  OrientationMode? _applied;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final OrientationMode mode = GameScope.of(context).orientationMode;
    if (mode == _applied) return;
    _applied = mode;
    unawaited(applyOrientationMode(mode));
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Shows the welcome screen once, then the caller for every later launch.
class _RootScreen extends StatelessWidget {
  const _RootScreen();

  @override
  Widget build(BuildContext context) {
    final GameController game = GameScope.of(context);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: game.hasSeenWelcome
          ? const HomeScreen(key: ValueKey<String>('home'))
          : const WelcomeScreen(key: ValueKey<String>('welcome')),
    );
  }
}
