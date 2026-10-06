import 'package:flutter/material.dart';

/// Above the XP reward card, rather than underneath its five-second hold.
void showExerciseCompletionUndo(
  BuildContext context, {
  required String exerciseName,
  required VoidCallback onUndo,
}) {
  final scheme = Theme.of(context).colorScheme;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        '$exerciseName completed',
        style: TextStyle(color: scheme.onSurface),
      ),
      duration: const Duration(seconds: 8),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 190),
      backgroundColor: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      action: SnackBarAction(
        label: 'UNDO',
        textColor: scheme.primary,
        onPressed: onUndo,
      ),
    ),
  );
}
