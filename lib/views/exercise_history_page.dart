import 'package:flutter/material.dart';
import 'package:gym_app/database/database.dart';
import 'package:gym_app/logic/exercise_progress.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/services/gamification_service.dart';
import 'package:gym_app/widgets/edit_set_dialog.dart';
import 'package:gym_app/widgets/exercise_volume_chart.dart';

class ExerciseHistoryPage extends StatefulWidget {
  const ExerciseHistoryPage({
    super.key,
    required this.exercise,
    required this.database,
    required this.service,
  });
  final Exercise exercise;
  final AppDatabase database;
  final GamificationService service;
  @override
  State<ExerciseHistoryPage> createState() => _ExerciseHistoryPageState();
}

class _ExerciseHistoryPageState extends State<ExerciseHistoryPage> {
  late Future<List<HistoryEntry>> _history;
  bool _saving = false;
  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _history = widget.database.getPerformanceHistoryForExercise(
      widget.exercise.id,
      legacyExerciseName: widget.exercise.name,
      limit: null,
    );
  }

  Future<void> _edit(HistoryEntry row) async {
    final result = await showEditSetDialog(
      context,
      weight: row.weight,
      reps: row.reps,
    );
    if (result == null || !mounted) return;
    setState(() => _saving = true);
    try {
      await widget.service.editHistorySet(
        row.id,
        weight: result.weight,
        reps: result.reps,
      );
      if (mounted) setState(_reload);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not update this set. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Progress & history')),
    body: FutureBuilder<List<HistoryEntry>>(
      future: _history,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Could not load history.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final sessions = summarizeExerciseProgress(snapshot.data!);
        final bestSets =
            sessions.map((s) => s.bestSet).whereType<HistoryEntry>().toList()
              ..sort((a, b) {
                final weight = b.weight.compareTo(a.weight);
                return weight != 0 ? weight : b.reps.compareTo(a.reps);
              });
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.exercise.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${sessions.length} completed ${sessions.length == 1 ? 'session' : 'sessions'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (bestSets.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Best recorded set · ${formatWeight(bestSets.first.weight)} lbs × ${bestSets.first.reps}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(sessionComparison(sessions)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ExerciseVolumeChart(sessions: sessions),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Warmups and abandoned attempts don’t affect progress. Best set = heaviest working set, then most reps.',
              ),
            ),
            if (sessions.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('Complete an exercise to start your history.'),
              ),
            for (final session in sessions)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${session.date.month}/${session.date.day}/${session.date.year}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text('Volume · ${formatWeight(session.volume)} lb·reps'),
                      if (session.bestSet case final best?)
                        Text(
                          'Best · ${formatWeight(best.weight)} lbs × ${best.reps}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      for (final row in session.sets.reversed)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            '${formatWeight(row.weight)} lbs × ${row.reps}',
                          ),
                          subtitle: row.isWarmup ? const Text('Warmup') : null,
                          trailing: IconButton(
                            tooltip: 'Correct set',
                            onPressed: _saving ? null : () => _edit(row),
                            icon: const Icon(Icons.edit_outlined),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
