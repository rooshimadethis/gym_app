import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym_app/models.dart';

class NextExerciseModal extends StatelessWidget {
  final List<Exercise> nextExercises;
  final String currentExerciseName;
  final int currentPosition;
  final int totalExercises;

  const NextExerciseModal({
    super.key,
    required this.nextExercises,
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
            'Exercise ${((currentPosition + 1) % totalExercises) + 1}/$totalExercises',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          ...nextExercises.map(
            (exercise) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(exercise);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  nextExercises.length > 1
                      ? exercise.name
                      : 'Start ${exercise.name}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
