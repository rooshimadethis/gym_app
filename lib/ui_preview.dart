// Development entry point: flutter run -t lib/ui_preview.dart
// Uses production widgets without opening or modifying the workout database.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'database/database.dart';
import 'models/models.dart';
import 'domain/gamification.dart';
import 'services/gamification_service.dart';
import 'views/workout_completion_page.dart';
import 'views/exercise_history_page.dart';
import 'widgets/workout_feedback_overlay.dart';
import 'widgets/workout_finish_dialog.dart';
import 'widgets/fatigue_check_in_modal.dart';
import 'widgets/exercise_xp_tier_selector.dart';
import 'widgets/exercise_completion_undo.dart';

void main() {
  runApp(const FeedbackPreviewApp());
}

Future<void> _previewHistory(BuildContext context) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  final service = GamificationService(database);
  try {
    for (var session = 0; session < 4; session++) {
      for (var set = 0; set < 3; set++) {
        await database.addHistoryEntry(
          HistoryEntriesCompanion.insert(
            exerciseName: 'Chest Press',
            exerciseId: const Value('preview-chest'),
            weight: 100,
            reps: 8 + session - set,
            timestamp: DateTime.now().subtract(
              Duration(days: (3 - session) * 7, minutes: 2 - set),
            ),
            workoutPosition: 1,
            fatigueScore: 0,
            sessionId: 'preview-$session',
          ),
        );
      }
    }
    if (!context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseHistoryPage(
          exercise: Exercise(id: 'preview-chest', name: 'Chest Press'),
          database: database,
          service: service,
        ),
      ),
    );
  } finally {
    service.dispose();
    await database.close();
  }
}

void _previewXp(
  BuildContext context, {
  int xp = 3,
  bool effort = false,
  int lifetimeXp = 88,
}) {
  showXpGainFeedback(
    context,
    xp: xp,
    effort: effort,
    before: GamificationService.levelProgressForXp(lifetimeXp),
    after: GamificationService.levelProgressForXp(lifetimeXp + xp),
  );
}

class FeedbackPreviewApp extends StatelessWidget {
  const FeedbackPreviewApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'StackSansText',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF77A26D),
        brightness: Brightness.dark,
        primary: const Color(0xFF77A26D),
        surface: const Color(0xFF121212),
        onSurface: Colors.white,
        surfaceContainerHighest: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
    ),
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(title: const Text('Workout UI preview')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            FilledButton(
              onPressed: () => _previewHistory(context),
              child: const Text('Progress & corrections'),
            ),
            FilledButton(
              onPressed: () {
                _previewXp(context, xp: 18);
                showExerciseCompletionUndo(
                  context,
                  exerciseName: 'Chest Press',
                  onUndo: dismissXpGainFeedback,
                );
              },
              child: const Text('Completion undo + XP'),
            ),
            FilledButton(
              onPressed: () => showExerciseXpTierDialog(
                context,
                exerciseName: 'Chest Press',
                initialTier: ExerciseXpTier.standard,
              ),
              child: const Text('Edit effort tier'),
            ),
            FilledButton(
              onPressed: () => showDialog<int>(
                context: context,
                builder: (_) => const FatigueCheckInModal(),
              ),
              child: const Text('Exercise start check-in'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _KeyboardPreview(),
                ),
              ),
              child: const Text('Set XP with keyboard'),
            ),
            FilledButton(
              onPressed: () => showWorkoutStartCelebration(context),
              child: const Text('Start celebration'),
            ),
            FilledButton(
              onPressed: () => _previewXp(context),
              child: const Text('Set XP'),
            ),
            FilledButton(
              onPressed: () => _previewXp(context, xp: 2, effort: true),
              child: const Text('Partial XP'),
            ),
            FilledButton(
              onPressed: () => _previewXp(context, lifetimeXp: 98),
              child: const Text('Level-up XP'),
            ),
            FilledButton(
              onPressed: () => showFinishWorkoutDialog(context, bankedXp: 24),
              child: const Text('Finish dialog'),
            ),
            for (final completed in [true, false])
              FilledButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkoutCompletionPage(
                      breakdown: XpBreakdown(
                        setCompletedXp: 18,
                        setFailedXp: 2,
                        exerciseCompletedXp: completed ? 15 : 0,
                        workoutCompletedXp: completed ? 40 : 0,
                      ),
                      levelProgress: const XpLevelProgress(
                        level: 2,
                        lifetimeXp: 156,
                        xpIntoLevel: 56,
                        xpForNextLevel: 125,
                      ),
                      completedWorkout: completed,
                    ),
                  ),
                ),
                child: Text(
                  completed ? 'Completed receipt' : 'Partial receipt',
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _KeyboardPreview extends StatelessWidget {
  const _KeyboardPreview();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Set feedback preview')),
    body: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Next set reps'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => _previewXp(context),
            child: const Text('Log set · +3 XP'),
          ),
        ],
      ),
    ),
  );
}
