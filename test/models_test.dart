import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/models/models.dart';

void main() {
  group('Exercise session progress', () {
    test('is complete only after every set has been logged', () {
      final exercise = Exercise(name: 'Test exercise');

      exercise.markSetCompleted(0);
      exercise.markSetCompleted(1);

      expect(exercise.isSessionComplete, isFalse);

      exercise.markSetCompleted(2);

      expect(exercise.isSessionComplete, isTrue);
    });

    test('ignores duplicate and out-of-range completion markers', () {
      final exercise = Exercise(name: 'Test exercise');

      exercise.markSetCompleted(0);
      exercise.markSetCompleted(0);
      exercise.markSetCompleted(-1);
      exercise.markSetCompleted(3);

      expect(exercise.sessionCompletedSetIndices, {0});
      expect(exercise.isSessionComplete, isFalse);
    });

    test('reset clears all session-only state', () {
      final exercise = Exercise(
        name: 'Test exercise',
        sessionFatigueScore: 1,
        currentSetIndex: 2,
        sessionCompletedSetIndices: {0, 1, 2},
      );

      exercise.resetSessionProgress();

      expect(exercise.currentSetIndex, 0);
      expect(exercise.sessionFatigueScore, isNull);
      expect(exercise.sessionCompletedSetIndices, isEmpty);
    });
  });
}
