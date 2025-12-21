import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NextExerciseModal extends StatelessWidget {
  final String nextExerciseName;
  final String currentExerciseName;
  final int currentPosition;
  final int totalExercises;

  const NextExerciseModal({
    super.key,
    required this.nextExerciseName,
    required this.currentExerciseName,
    required this.currentPosition,
    required this.totalExercises,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Next Exercise'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Completed: $currentExerciseName',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Icon(
            Icons.arrow_downward,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            nextExerciseName,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Exercise ${currentPosition + 2}/$totalExercises',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
