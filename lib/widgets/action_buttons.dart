import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// The primary call-to-action: draw the next number.
class GenerateButton extends StatelessWidget {
  const GenerateButton({
    super.key,
    required this.onPressed,
    this.height = 72,
    this.label = 'GENERATE NUMBER',
  });

  final VoidCallback? onPressed;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.mediumImpact();
                onPressed!.call();
              },
        icon: const Icon(Icons.casino_rounded, size: 28),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Replays the current announcement without drawing a new number.
class RepeatButton extends StatelessWidget {
  const RepeatButton({
    super.key,
    required this.onPressed,
    this.height = 58,
    this.label = 'REPEAT NUMBER',
  });

  final VoidCallback? onPressed;
  final double height;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.volume_up_rounded, size: 26),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
