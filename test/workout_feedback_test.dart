import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/views/workout_completion_page.dart';
import 'package:gym_app/widgets/workout_feedback_overlay.dart';

void main() {
  testWidgets('workout start feedback is non-blocking and self-dismisses', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showWorkoutStartCelebration(context),
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Start'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.text('WORKOUT STARTED'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('WORKOUT STARTED'), findsNothing);
  });

  testWidgets('completion page shows XP breakdown and level progress', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WorkoutCompletionPage(
          breakdown: XpBreakdown(
            setCompletedXp: 6,
            exerciseCompletedXp: 10,
            workoutCompletedXp: 40,
          ),
          levelProgress: XpLevelProgress(
            level: 2,
            lifetimeXp: 156,
            xpIntoLevel: 56,
            xpForNextLevel: 125,
          ),
          completedWorkout: true,
        ),
      ),
    );

    expect(find.text('WORKOUT COMPLETE'), findsOneWidget);
    expect(find.text('+56 XP'), findsOneWidget);
    expect(find.text('LEVEL 2'), findsOneWidget);
    expect(find.text('56 / 125'), findsOneWidget);
  });
}
