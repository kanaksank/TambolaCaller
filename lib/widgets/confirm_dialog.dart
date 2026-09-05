import 'package:flutter/material.dart';

/// "Start a new game?" — the only destructive action in the app, so it always
/// asks first.
Future<bool> confirmNewGame(BuildContext context, {bool isReset = false}) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isReset ? 'Reset this game?' : 'Start a new game?'),
        content: const Text('This will clear all previously called numbers.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(isReset ? 'RESET' : 'NEW GAME'),
          ),
        ],
      );
    },
  );
  return confirmed ?? false;
}
