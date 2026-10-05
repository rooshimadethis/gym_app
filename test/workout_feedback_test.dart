import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/services/gamification_service.dart';
import 'package:gym_app/views/workout_completion_page.dart';
import 'package:gym_app/widgets/workout_feedback_overlay.dart';
import 'package:gym_app/widgets/workout_finish_dialog.dart';
import 'package:gym_app/widgets/exercise_xp_tier_selector.dart';
import 'package:gym_app/widgets/fatigue_check_in_modal.dart';

void main() {
  testWidgets('set XP stays above the keyboard without stealing focus', (
    tester,
  ) async {
    addTearDown(tester.view.resetViewInsets);
    final focus = FocusNode();
    addTearDown(focus.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                TextField(focusNode: focus, autofocus: true),
                FilledButton(
                  onPressed: () => showXpGainFeedback(
                    context,
                    xp: 3,
                    before: GamificationService.levelProgressForXp(88),
                    after: GamificationService.levelProgressForXp(91),
                  ),
                  child: const Text('Log'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Log'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pump(const Duration(milliseconds: 450));
    expect(find.text('Set +3 XP'), findsOneWidget);
    expect(find.text('Level 1'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .88,
    );
    final keyboardTop =
        (tester.view.physicalSize.height - tester.view.viewInsets.bottom) /
        tester.view.devicePixelRatio;
    expect(
      tester.getRect(find.text('Set +3 XP')).bottom,
      lessThan(keyboardTop),
    );
    expect(focus.hasFocus, isTrue);
    final style = DefaultTextStyle.of(
      tester.element(find.text('Set +3 XP')),
    ).style;
    expect(style.decoration, isNot(TextDecoration.underline));
    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('9 XP to Level 2'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value,
      .91,
    );
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Set +3 XP'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Set +3 XP'), findsNothing);
  });

  for (final reducedMotion in [false, true]) {
    testWidgets(
      'XP handles a level boundary with reduced motion $reducedMotion',
      (tester) async {
        if (reducedMotion) {
          tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
              const FakeAccessibilityFeatures(disableAnimations: true);
          addTearDown(
            tester
                .binding
                .platformDispatcher
                .clearAccessibilityFeaturesTestValue,
          );
        }
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: MediaQueryData(disableAnimations: reducedMotion),
              child: Builder(
                builder: (context) => Scaffold(
                  body: TextButton(
                    onPressed: () => showXpGainFeedback(
                      context,
                      xp: 3,
                      before: GamificationService.levelProgressForXp(98),
                      after: GamificationService.levelProgressForXp(101),
                    ),
                    child: const Text('Award'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Award'));
        await tester.pump();
        if (!reducedMotion) {
          await tester.pump(const Duration(milliseconds: 1200));
          expect(find.text('100 / 100 XP'), findsOneWidget);
          expect(
            tester
                .widget<LinearProgressIndicator>(
                  find.byType(LinearProgressIndicator),
                )
                .value,
            1,
          );
          await tester.pump(const Duration(milliseconds: 800));
        } else {
          await tester.pump(const Duration(seconds: 2));
        }
        expect(find.text('LEVEL UP! · 2'), findsOneWidget);
        expect(find.text('124 XP to Level 3'), findsOneWidget);
        expect(
          tester
              .widget<LinearProgressIndicator>(
                find.byType(LinearProgressIndicator),
              )
              .value,
          1 / 125,
        );
        expect(tester.takeException(), isNull);
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('Set +3 XP'), findsNothing);
      },
    );
  }

  testWidgets('consecutive set and exercise awards share one reward card', (
    tester,
  ) async {
    late BuildContext rewardContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            rewardContext = context;
            return const Scaffold();
          },
        ),
      ),
    );
    showXpGainFeedback(
      rewardContext,
      xp: 3,
      before: GamificationService.levelProgressForXp(88),
      after: GamificationService.levelProgressForXp(91),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    showXpGainFeedback(
      rewardContext,
      xp: 15,
      label: 'Exercise',
      before: GamificationService.levelProgressForXp(91),
      after: GamificationService.levelProgressForXp(106),
    );
    await tester.pump();
    expect(find.text('Earned +18 XP'), findsOneWidget);
    expect(find.text('Set +3 XP'), findsNothing);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('119 XP to Level 3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
  });
  testWidgets(
    'effort editor fits a narrow screen and saves the selected tier',
    (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ExerciseXpTier? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () async {
                  result = await showExerciseXpTierDialog(
                    context,
                    exerciseName: 'Chest Press',
                    initialTier: ExerciseXpTier.standard,
                  );
                },
                child: const Text('Edit'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Demanding'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save effort'));
      await tester.pumpAndSettle();
      expect(result, ExerciseXpTier.demanding);
    },
  );

  testWidgets('energy check-in returns the existing fatigue score', (
    tester,
  ) async {
    int? result;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                result = await showDialog<int>(
                  context: context,
                  builder: (_) => const FatigueCheckInModal(),
                );
              },
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fatigued'));
    await tester.pumpAndSettle();
    expect(result, 1);
  });
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
    expect(find.text('Workout started'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Workout started'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Workout started'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Workout started'), findsNothing);
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
    expect(find.text('+56'), findsOneWidget);
    expect(find.text('Level 2'), findsOneWidget);
    expect(find.text('56 / 125 XP'), findsOneWidget);
  });

  testWidgets('finish dialog makes banked XP and choices clear', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: FilledButton(
              onPressed: () => showFinishWorkoutDialog(context, bankedXp: 24),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Finish workout?'), findsOneWidget);
    expect(find.text('+24 XP'), findsOneWidget);
    expect(find.text('Finish workout'), findsOneWidget);
    expect(find.text('Keep going'), findsOneWidget);
  });
}
