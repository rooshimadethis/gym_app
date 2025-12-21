import 'package:flutter/material.dart';
import 'package:gym_app/exercise_card.dart';
import 'package:gym_app/models.dart';
import 'package:gym_app/exercise_detail_view.dart';

class AlternativeExerciseGroup extends StatelessWidget {
  final List<Exercise> alternatives;
  final Function(Exercise) onExerciseCompleted;
  final Function(Exercise) onLongPress;
  final VoidCallback onTap;
  final SupersetInfo Function(Exercise)? getSupersetInfo;

  const AlternativeExerciseGroup({
    super.key,
    required this.alternatives,
    required this.onExerciseCompleted,
    required this.onLongPress,
    required this.onTap,
    this.getSupersetInfo,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: alternatives.length,
        itemBuilder: (context, index) {
          final exercise = alternatives[index];
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16.0 : 8.0,
              right: index == alternatives.length - 1 ? 16.0 : 8.0,
            ),
            child: SizedBox(
              width: 300,
              child: ExerciseCard(
                exercise: exercise,
                onExerciseCompleted: () => onExerciseCompleted(exercise),
                onLongPress: () => onLongPress(exercise),
                onTap: onTap,
                getSupersetInfo: getSupersetInfo,
              ),
            ),
          );
        },
      ),
    );
  }
}
