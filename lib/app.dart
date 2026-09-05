import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'services/game_controller.dart';
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
        home: const _RootScreen(),
      ),
    );
  }
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
