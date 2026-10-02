import 'dart:async';
import 'package:gym_app/widgets/exercise_card.dart';
import 'package:gym_app/widgets/alternative_exercise_group.dart';
import 'package:gym_app/widgets/superset_exercise_group.dart';
import 'package:gym_app/views/exercise_detail_view.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/models/models.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/views/settings_page.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gym_app/services/stopwatch_task_handler.dart';
import 'package:gym_app/database/database.dart';
import 'package:gym_app/services/workout_session_manager.dart';
import 'package:gym_app/logic/priority_manager.dart';
import 'package:gym_app/services/rest_timer_manager.dart';
import 'package:drift/drift.dart' as drift;
import 'package:gym_app/widgets/rest_timer_overlay.dart';
import 'package:gym_app/services/theme_manager.dart';
import 'package:gym_app/widgets/exercise_xp_tier_selector.dart';
import 'package:gym_app/services/gamification_service.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';
import 'package:gym_app/views/workout_completion_page.dart';
import 'package:gym_app/widgets/session_progress_strip.dart';
import 'package:gym_app/widgets/workout_feedback_overlay.dart';

late AppDatabase db;
late GamificationService gamificationService;

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  db = AppDatabase();
  gamificationService = GamificationService(db);
  WorkoutSessionManager.instance.configureGamification(gamificationService);
  await ThemeManager.instance.init();
  await WorkoutFeedbackSettings.instance.init();
  await WorkoutSessionManager.instance.init();
  await RestTimerManager.instance.init();
  await FlutterDisplayMode.setHighRefreshRate();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-check session expiry when app comes to foreground
      WorkoutSessionManager.instance.init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'rooshi\'s get swole',
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: 'StackSansText',
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF4C763B),
              brightness: Brightness.light,
              primary: const Color(0xFF4C763B),
              surface: const Color(0xFFFBFDF7),
              onSurface: const Color(0xFF1A1C18),
              surfaceContainerHighest: const Color(0xFFE1E4D5),
            ),
            scaffoldBackgroundColor: const Color(0xFFFBFDF7),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Color(0xFF1A1C18),
              ),
              iconTheme: IconThemeData(color: Color(0xFF1A1C18)),
            ),
            cardTheme: CardThemeData(
              elevation: 4,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: Colors.white,
            ),
          ),
          darkTheme: ThemeData(
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
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: false,
              titleTextStyle: TextStyle(
                fontFamily: 'StackSansText',
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
              toolbarTextStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white54,
              ),
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              color: const Color(0xFF1E1E1E).withValues(alpha: 0.5),
            ),
          ),
          themeMode: ThemeManager.instance.themeMode,
          home: const MyHomePage(title: 'rooshi\'s get swole'),
          builder: (context, child) {
            return Stack(
              children: [if (child != null) child, const RestTimerOverlay()],
            );
          },
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Exercise> _allExercises = [];
  List<Exercise> _filteredExercises = [];
  final TextEditingController _searchController = TextEditingController();
  Map<String, int> _supersetProgress =
      {}; // Track current position in each superset
  String? _observedSessionId;

  final Map<String, String> _exerciseImageMap = {
    'Chest Press': 'assets/images/exercises/chest-press.webp',
    'Lat Pull Down': 'assets/images/exercises/lat-pulldown.webp',
    'Cable Row': 'assets/images/exercises/cable-row.webp',
    'Leg Press': 'assets/images/exercises/leg-press.webp',
    'Calf Raise': 'assets/images/exercises/calf-raise.webp',
    'Hamstring Curl': 'assets/images/exercises/hamstring-curl.webp',
    'Dumbbell Lateral Raise': 'assets/images/exercises/lateral-raise.webp',
    'Dumbbell Shoulder Press': 'assets/images/exercises/shoulder-press.webp',
    'Tricep Pushdown': 'assets/images/exercises/tricep-pushdown.webp',
    'Bicep Curl': 'assets/images/exercises/bicep-curl.webp',
    'Wrist Curls': 'assets/images/exercises/wrist-curl.webp',
    'Cable Shrug': 'assets/images/exercises/cable-shrug.webp',
    'Deadlift': 'assets/images/exercises/deadlift.webp',
  };

  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      await rootBundle.load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _observedSessionId = WorkoutSessionManager.instance.currentSessionId;
    WorkoutSessionManager.instance.addListener(_handleWorkoutSessionChanged);
    _loadExercises();
    _loadSupersetProgress();
    _searchController.addListener(() {
      filterExercises();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPendingAutomaticSummary();
    });
  }

  Future<void> _showPendingAutomaticSummary() async {
    final session = await gamificationService.pendingAutomaticSession;
    if (session == null) return;
    final breakdown = await gamificationService.breakdownForSession(
      session.sessionId,
    );
    await gamificationService.markCompletionSummarySeen(session.sessionId);
    if (!mounted || breakdown.total == 0) return;
    final progress = await gamificationService.levelProgress;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Previous workout closed automatically · ${breakdown.total} XP preserved',
        ),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutCompletionPage(
                  breakdown: breakdown,
                  levelProgress: progress,
                  completedWorkout: false,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleWorkoutSessionChanged() {
    final currentSessionId = WorkoutSessionManager.instance.currentSessionId;
    if (currentSessionId == _observedSessionId) return;

    _observedSessionId = currentSessionId;
    if (!mounted) return;

    setState(() {
      for (final exercise in _allExercises) {
        exercise.resetSessionProgress();
      }
      _supersetProgress.updateAll((_, _) => 0);
    });
  }

  Future<void> _loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString('exercises_data');
    if (exercisesJson == null) {
      _allExercises = [
        Exercise(name: 'Chest Press'),
        Exercise(name: 'Lat Pull Down'),
        Exercise(name: 'Cable Row'),
        Exercise(name: 'Leg Press'),
        Exercise(name: 'Calf Raise'),
        Exercise(name: 'Hamstring Curl'),
        Exercise(name: 'Dumbbell Lateral Raise'),
        Exercise(name: 'Dumbbell Shoulder Press'),
        Exercise(name: 'Tricep Pushdown'),
        Exercise(name: 'Bicep Curl'),
        Exercise(name: 'Wrist Curls'),
        Exercise(name: 'Cable Shrug'),
        Exercise(name: 'Deadlift'),
      ];
      for (var exercise in _allExercises) {
        final assetPath = _exerciseImageMap[exercise.name];
        if (assetPath != null) {
          exercise.hasLocalImage = await _checkAssetExists(assetPath);
          if (exercise.hasLocalImage) {
            exercise.imageUrl = assetPath;
          }
        }
      }
    } else {
      final exercisesList = jsonDecode(exercisesJson) as List;
      final needsExerciseMetadataMigration = exercisesList.any(
        (json) =>
            json is Map<String, dynamic> &&
            Exercise.metadataNeedsMigration(json),
      );
      _allExercises = exercisesList
          .map((json) => Exercise.fromJson(json))
          .toList();
      if (needsExerciseMetadataMigration) {
        // Persist generated IDs and defaulted tiers so they remain stable on
        // the next launch.
        await _saveExercises();
      }
      // Re-check asset existence for loaded exercises in case assets changed
      for (var exercise in _allExercises) {
        final assetPath = _exerciseImageMap[exercise.name];
        if (assetPath != null) {
          exercise.hasLocalImage = await _checkAssetExists(assetPath);
          if (exercise.hasLocalImage) {
            exercise.imageUrl = assetPath;
          }
        }
      }
    }
    await _migrateLegacyHistory();
    await _refreshPriorities();
    filterExercises();
  }

  Future<void> _migrateLegacyHistory() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('legacy_drift_migration_v1') ?? false) return;

    final timestamp = DateTime.now();
    final sessionId = 'legacy_import_${timestamp.millisecondsSinceEpoch}';

    // check if we have any data to migrate
    bool hasData = _allExercises.any(
      (e) => e.sets.any(
        (s) => s.weight.isNotEmpty && double.tryParse(s.weight) != null,
      ),
    );

    if (hasData) {
      await db.batch((batch) {
        for (var exercise in _allExercises) {
          for (var set in exercise.sets) {
            final weight = double.tryParse(set.weight);
            if (weight != null) {
              batch.insert(
                db.historyEntries,
                HistoryEntriesCompanion.insert(
                  exerciseName: exercise.name,
                  weight: weight,
                  reps: int.tryParse(set.reps) ?? 0,
                  // Assume not warmup for legacy data migration
                  isWarmup: const drift.Value(false),
                  timestamp: timestamp,
                  workoutPosition: 0,
                  fatigueScore: 0, // Neutral fatigue for imported data
                  sessionId: sessionId,
                ),
              );
            }
          }
        }
      });
      debugPrint('Migrated legacy history to Drift database');
    }

    await prefs.setBool('legacy_drift_migration_v1', true);
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = jsonEncode(
      _allExercises.map((e) => e.toJson()).toList(),
    );
    await prefs.setString('exercises_data', exercisesJson);
  }

  Future<void> _loadSupersetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString('superset_progress');
    if (progressJson != null) {
      setState(() {
        _supersetProgress = Map<String, int>.from(jsonDecode(progressJson));
      });
    }
  }

  Future<void> _saveSupersetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('superset_progress', jsonEncode(_supersetProgress));
  }

  void _onSupersetProgress(Exercise exercise) {
    setState(() {
      final currentIndex = _supersetProgress[exercise.supersetId!] ?? 0;
      _supersetProgress[exercise.supersetId!] = currentIndex + 1;
      _saveSupersetProgress();
    });
  }

  List<Exercise> _getSupersetExercises(String supersetId) {
    return _allExercises.where((e) => e.supersetId == supersetId).toList()
      ..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));
  }

  Future<void> _refreshPriorities() async {
    final freshDates = Map.fromEntries(
      await Future.wait(
        _allExercises.map((exercise) async {
          final date = await db.getLastFreshDateForExercise(
            exercise.id,
            exercise.name,
          );
          return MapEntry(exercise.id, date);
        }),
      ),
    );
    if (mounted) {
      setState(() {
        for (var exercise in _allExercises) {
          exercise.isHighPriority = PriorityManager.isHighPriority(
            freshDates[exercise.id],
          );
        }
      });
    }
  }

  void filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises
          .where((exercise) => exercise.name.toLowerCase().contains(query))
          .toList();
    });
  }

  List<List<Exercise>> _getDisplayGroups() {
    final Map<String, List<Exercise>> groups = {};
    final Set<String> processedSupersets = {};

    for (var exercise in _filteredExercises) {
      // If exercise is part of superset, group all superset exercises together
      if (exercise.isPartOfSuperset) {
        if (!processedSupersets.contains(exercise.supersetId)) {
          final supersetExercises =
              _filteredExercises
                  .where((e) => e.supersetId == exercise.supersetId)
                  .toList()
                ..sort(
                  (a, b) =>
                      (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0),
                );
          groups['superset_${exercise.supersetId}'] = supersetExercises;
          processedSupersets.add(exercise.supersetId!);
        }
      } else {
        // Regular grouping for alternatives
        final key = exercise.groupId ?? 'standalone_${exercise.name}';
        groups.putIfAbsent(key, () => []).add(exercise);
      }
    }

    return groups.values.toList();
  }

  void _moveExerciseToBottom(Exercise exercise) {
    setState(() {
      if (exercise.isPartOfSuperset) {
        // Move entire superset to bottom
        final supersetExercises = _allExercises
            .where((e) => e.supersetId == exercise.supersetId)
            .toList();

        // Reset session-only state for all exercises in the completed superset.
        for (var e in supersetExercises) {
          e.resetSessionProgress();
        }

        // Remove all from list
        _allExercises.removeWhere((e) => e.supersetId == exercise.supersetId);

        // Sort by supersetOrder and add to bottom
        supersetExercises.sort(
          (a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0),
        );
        _allExercises.addAll(supersetExercises);

        // Reset superset progress
        _supersetProgress[exercise.supersetId!] = 0;
        _saveSupersetProgress();
      } else if (exercise.isPartOfGroup) {
        // Find all exercises with same groupId
        final groupExercises = _allExercises
            .where((e) => e.groupId == exercise.groupId)
            .toList();

        // Reset session-only state for all alternatives in the completed group.
        for (var e in groupExercises) {
          e.resetSessionProgress();
        }

        // Remove all from list
        _allExercises.removeWhere((e) => e.groupId == exercise.groupId);

        // Add all to bottom
        _allExercises.addAll(groupExercises);
      } else {
        // Single exercise
        exercise.resetSessionProgress();
        _allExercises.remove(exercise);
        _allExercises.add(exercise);
      }
      filterExercises();
      _refreshPriorities(); // Refresh on completion
    });
    _saveExercises();
  }

  bool _imagesPrecached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_imagesPrecached) {
      _precacheImages();
      _imagesPrecached = true;
    }
  }

  Future<void> _precacheImages() async {
    for (var exercise in _allExercises) {
      if (exercise.hasLocalImage && exercise.imageUrl != null) {
        await precacheImage(AssetImage(exercise.imageUrl!), context);
      }
    }
  }

  @override
  void dispose() {
    WorkoutSessionManager.instance.removeListener(_handleWorkoutSessionChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showAddExerciseDialog() async {
    final TextEditingController newExerciseController = TextEditingController();
    var selectedTier = ExerciseXpTier.standard;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Exercise'),
          content: StatefulBuilder(
            builder: (context, setDialogState) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newExerciseController,
                  decoration: const InputDecoration(hintText: 'Exercise Name'),
                  autofocus: true,
                ),
                const SizedBox(height: 20),
                ExerciseXpTierSelector(
                  value: selectedTier,
                  onChanged: (tier) =>
                      setDialogState(() => selectedTier = tier),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final newExerciseName = newExerciseController.text.trim();
                if (newExerciseName.isNotEmpty) {
                  final newExercise = Exercise(
                    name: newExerciseName,
                    xpTier: selectedTier,
                  );
                  final assetPath = _exerciseImageMap[newExercise.name];
                  if (assetPath != null) {
                    newExercise.hasLocalImage = await _checkAssetExists(
                      assetPath,
                    );
                    if (newExercise.hasLocalImage) {
                      newExercise.imageUrl = assetPath;
                    }
                  }

                  if (context.mounted) {
                    setState(() {
                      _allExercises.insert(0, newExercise);
                      filterExercises();
                    });
                    _saveExercises();
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _startWorkout() async {
    await WorkoutSessionManager.instance.startWorkout();
    if (!mounted) return;
    await showWorkoutStartCelebration(context);
  }

  Future<void> _endWorkout() async {
    final sessionId = WorkoutSessionManager.instance.currentSessionId;
    if (sessionId == null) return;
    final currentBreakdown = await gamificationService.breakdownForSession(
      sessionId,
    );
    if (!mounted) return;

    if (currentBreakdown.total == 0) {
      final discard = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard empty workout?'),
          content: const Text('No sets were recorded in this session.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('KEEP WORKOUT'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('DISCARD'),
            ),
          ],
        ),
      );
      if (discard != true) return;
      await WorkoutSessionManager.instance.endWorkout(
        reason: WorkoutEndReason.discarded,
      );
      return;
    }

    final shouldEnd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finish this workout?'),
        content: Text('${currentBreakdown.total} XP is already banked.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('KEEP GOING'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('FINISH WORKOUT'),
          ),
        ],
      ),
    );
    if (shouldEnd != true) return;

    final endedSessionId = await WorkoutSessionManager.instance.endWorkout();
    if (endedSessionId == null) return;
    final breakdown = await gamificationService.breakdownForSession(
      endedSessionId,
    );
    final progress = await gamificationService.levelProgress;
    final crossedLevels = GamificationService.crossedLevels(
      progress.lifetimeXp - breakdown.total,
      progress.lifetimeXp,
    );
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WorkoutCompletionPage(
          breakdown: breakdown,
          levelProgress: progress,
          completedWorkout: breakdown.workoutCompletedXp > 0,
          levelsCrossed: crossedLevels,
        ),
      ),
    );
  }

  Future<void> _showEditExerciseDialog(Exercise exercise) async {
    var selectedTier = exercise.xpTier;
    final changed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Edit ${exercise.name}'),
          content: ExerciseXpTierSelector(
            value: selectedTier,
            onChanged: (tier) => setDialogState(() => selectedTier = tier),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (changed == true && mounted) {
      setState(() => exercise.xpTier = selectedTier);
      await _saveExercises();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _searchController.text.isEmpty,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        if (_searchController.text.isNotEmpty) {
          _searchController.clear();
          filterExercises();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
          title: Text(widget.title),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _showAddExerciseDialog,
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _loadExercises();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        floatingActionButton: ListenableBuilder(
          listenable: WorkoutSessionManager.instance,
          builder: (context, _) {
            final isRunning = WorkoutSessionManager.instance.isWorkoutActive;
            return FloatingActionButton.extended(
              onPressed: isRunning ? _endWorkout : _startWorkout,
              label: Text(isRunning ? 'End Workout' : 'Start Workout'),
              icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
              backgroundColor: isRunning
                  ? Colors.red
                  : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            );
          },
        ),
        body: Column(
          children: [
            ListenableBuilder(
              listenable: WorkoutSessionManager.instance,
              builder: (context, _) {
                final manager = WorkoutSessionManager.instance;
                final sessionId = manager.currentSessionId;
                final startedAt = manager.sessionStartTime;
                if (sessionId == null || startedAt == null) {
                  return const SizedBox.shrink();
                }
                return ListenableBuilder(
                  listenable: gamificationService,
                  builder: (context, _) =>
                      FutureBuilder<(int, XpLevelProgress)>(
                        future:
                            Future.wait<Object>([
                              gamificationService.sessionXp(sessionId),
                              gamificationService.levelProgress,
                            ]).then(
                              (values) => (
                                values[0] as int,
                                values[1] as XpLevelProgress,
                              ),
                            ),
                        builder: (context, snapshot) {
                          final data = snapshot.data;
                          return SessionProgressStrip(
                            startedAt: startedAt,
                            sessionXp: data?.$1 ?? 0,
                            level: data?.$2.level ?? 1,
                          );
                        },
                      ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Search exercises...',
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              filterExercises();
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 32),
                physics: const BouncingScrollPhysics(),
                itemCount: _getDisplayGroups().length,
                itemBuilder: (context, index) {
                  final group = _getDisplayGroups()[index];

                  Widget item;
                  if (group.isNotEmpty && group[0].isPartOfSuperset) {
                    final supersetId = group[0].supersetId!;
                    item = SupersetExerciseGroup(
                      key: ObjectKey(supersetId),
                      supersetExercises: group,
                      onExerciseCompleted: (exercise) {
                        _moveExerciseToBottom(exercise);
                        RestTimerManager.instance.start();
                      },
                      onLongPress: (exercise) =>
                          _showExerciseOptionsDialog(exercise),
                      onTap: () {},
                      currentExerciseIndex: _supersetProgress[supersetId] ?? 0,
                      onSupersetProgress: (exercise) =>
                          _onSupersetProgress(exercise),
                      getSupersetInfo: (exercise) {
                        final supersetExercises = _getSupersetExercises(
                          supersetId,
                        );

                        final int maxOrder =
                            supersetExercises.last.supersetOrder ?? 0;
                        final int currentOrder = exercise.supersetOrder ?? 0;
                        final bool isLast = currentOrder >= maxOrder;

                        final int nextOrder = isLast ? 0 : currentOrder + 1;

                        final nextExercises = supersetExercises
                            .where((e) => e.supersetOrder == nextOrder)
                            .toList();

                        return SupersetInfo(
                          isLastInSuperset: isLast,
                          nextExercises: nextExercises,
                          totalExercises: maxOrder + 1,
                          currentPosition: currentOrder,
                        );
                      },
                    );
                  } else if (group.length == 1) {
                    final exercise = group[0];
                    item = Padding(
                      key: ObjectKey(exercise),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: ExerciseCard(
                        exercise: exercise,
                        onExerciseCompleted: () {
                          _moveExerciseToBottom(exercise);
                          RestTimerManager.instance.start();
                        },
                        onLongPress: () => _showExerciseOptionsDialog(exercise),
                        onTap: () {},
                      ),
                    );
                  } else {
                    item = Padding(
                      key: ObjectKey(group[0].groupId),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AlternativeExerciseGroup(
                        alternatives: group,
                        onExerciseCompleted: (exercise) {
                          _moveExerciseToBottom(exercise);
                          RestTimerManager.instance.start();
                        },
                        onLongPress: (exercise) =>
                            _showExerciseOptionsDialog(exercise),
                        onTap: () {},
                      ),
                    );
                  }

                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutQuart,
                    tween: Tween(begin: 0.0, end: 1.0),
                    child: item,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 50 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showLinkAlternativeDialog(Exercise sourceExercise) async {
    // Get standalone exercises (not in any group, excluding source)
    final standaloneExercises = _allExercises
        .where((e) => e != sourceExercise && !e.isPartOfGroup)
        .toList();

    // Get existing groups (excluding source's group if it has one)
    final Map<String, List<Exercise>> existingGroups = {};
    for (var exercise in _allExercises) {
      if (exercise.isPartOfGroup &&
          exercise.groupId != sourceExercise.groupId) {
        existingGroups.putIfAbsent(exercise.groupId!, () => []).add(exercise);
      }
    }

    // Get current group members if source is grouped
    List<Exercise>? currentGroupMembers;
    if (sourceExercise.isPartOfGroup) {
      currentGroupMembers = _allExercises
          .where(
            (e) => e.groupId == sourceExercise.groupId && e != sourceExercise,
          )
          .toList();
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Link "${sourceExercise.name}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Show current group if source is already grouped
                if (currentGroupMembers != null &&
                    currentGroupMembers.isNotEmpty) ...[
                  const Text(
                    'Currently linked with:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...currentGroupMembers.map(
                    (e) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.link, size: 16),
                      title: Text(e.name),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // Section: Individual Exercises
                if (standaloneExercises.isNotEmpty) ...[
                  const Text(
                    'Individual Exercises:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...standaloneExercises.map((targetExercise) {
                    return ListTile(
                      title: Text(targetExercise.name),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          // Create or use existing groupId
                          final groupId =
                              sourceExercise.groupId ??
                              DateTime.now().millisecondsSinceEpoch.toString();

                          sourceExercise.groupId = groupId;
                          targetExercise.groupId = groupId;

                          filterExercises();
                          _saveExercises();
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],

                // Section: Join Existing Group
                if (existingGroups.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Join Existing Group:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...existingGroups.entries.map((entry) {
                    final groupExercises = entry.value;
                    final firstExerciseName = groupExercises.first.name;
                    final othersCount = groupExercises.length - 1;
                    final label = othersCount > 0
                        ? '$firstExerciseName + $othersCount other${othersCount > 1 ? 's' : ''}'
                        : firstExerciseName;

                    return ListTile(
                      leading: const Icon(Icons.workspaces),
                      title: Text(label),
                      subtitle: Text(
                        groupExercises.map((e) => e.name).join(', '),
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          sourceExercise.groupId = entry.key;
                          filterExercises();
                          _saveExercises();
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],

                // Show message if no options available
                if (standaloneExercises.isEmpty && existingGroups.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No exercises available to link. All exercises are already in groups.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showLinkSupersetDialog(Exercise sourceExercise) async {
    // Get exercises not in any superset (or in same superset)
    final availableExercises = _allExercises
        .where(
          (e) =>
              e != sourceExercise &&
              (!e.isPartOfSuperset ||
                  e.supersetId == sourceExercise.supersetId),
        )
        .toList();

    // Get existing supersets (excluding source's superset if it has one)
    final Map<String, List<Exercise>> existingSupersets = {};
    for (var exercise in _allExercises) {
      if (exercise.isPartOfSuperset &&
          exercise.supersetId != sourceExercise.supersetId) {
        existingSupersets
            .putIfAbsent(exercise.supersetId!, () => [])
            .add(exercise);
      }
    }

    // Sort each superset by order
    for (var exercises in existingSupersets.values) {
      exercises.sort(
        (a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0),
      );
    }

    // Get current superset members if source is in superset
    List<Exercise>? currentSupersetMembers;
    if (sourceExercise.isPartOfSuperset) {
      currentSupersetMembers =
          _allExercises
              .where(
                (e) =>
                    e.supersetId == sourceExercise.supersetId &&
                    e != sourceExercise,
              )
              .toList()
            ..sort(
              (a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0),
            );
    }

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Create Superset with "${sourceExercise.name}"'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Show current superset if source is already in one
                if (currentSupersetMembers != null &&
                    currentSupersetMembers.isNotEmpty) ...[
                  const Text(
                    'Currently in superset with:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...currentSupersetMembers.map(
                    (e) => ListTile(
                      dense: true,
                      leading: Text(
                        '${(e.supersetOrder ?? 0) + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      title: Text(e.name),
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                ],

                // Section: Individual Exercises
                if (availableExercises.isNotEmpty) ...[
                  const Text(
                    'Add Exercise to Superset:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...availableExercises.map((targetExercise) {
                    return ListTile(
                      title: Text(targetExercise.name),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          // Create or use existing supersetId
                          final supersetId =
                              sourceExercise.supersetId ??
                              'SS_${DateTime.now().millisecondsSinceEpoch}';

                          // If source doesn't have superset, assign it first
                          if (!sourceExercise.isPartOfSuperset) {
                            sourceExercise.supersetId = supersetId;
                            sourceExercise.supersetOrder = 0;
                          }

                          // Get next order number
                          final existingInSuperset = _allExercises
                              .where((e) => e.supersetId == supersetId)
                              .toList();
                          final nextOrder = existingInSuperset.length;

                          targetExercise.supersetId = supersetId;
                          targetExercise.supersetOrder = nextOrder;

                          filterExercises();
                          _saveExercises();
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],

                // Section: Join Existing Superset
                if (existingSupersets.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Add to Existing Superset:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ...existingSupersets.entries.map((entry) {
                    final supersetExercises = entry.value;
                    final exerciseNames = supersetExercises
                        .map((e) => '${(e.supersetOrder ?? 0) + 1}. ${e.name}')
                        .join(' → ');

                    return ListTile(
                      leading: const Icon(Icons.layers),
                      title: Text('${supersetExercises.length} exercises'),
                      subtitle: Text(
                        exerciseNames,
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          final nextOrder = supersetExercises.length;
                          sourceExercise.supersetId = entry.key;
                          sourceExercise.supersetOrder = nextOrder;
                          filterExercises();
                          _saveExercises();
                        });
                        Navigator.of(context).pop();
                      },
                    );
                  }),
                ],

                // Show message if no options available
                if (availableExercises.isEmpty && existingSupersets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'No exercises available. All exercises are already in supersets.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showExerciseOptionsDialog(Exercise exercise) async {
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(exercise.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit XP effort tier'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  _showEditExerciseDialog(exercise);
                },
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Link as Alternative'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  _showLinkAlternativeDialog(exercise);
                },
              ),
              if (exercise.isPartOfGroup)
                ListTile(
                  leading: const Icon(Icons.link_off),
                  title: const Text('Unlink from Alternatives'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      final oldGroupId = exercise.groupId;
                      exercise.groupId = null;

                      // Check if only 1 exercise remains in the group
                      final remainingInGroup = _allExercises
                          .where((e) => e.groupId == oldGroupId)
                          .toList();

                      if (remainingInGroup.length == 1) {
                        remainingInGroup.first.groupId = null;
                      }

                      filterExercises();
                      _saveExercises();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.layers),
                title: const Text('Create/Join Superset'),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  _showLinkSupersetDialog(exercise);
                },
              ),
              if (exercise.isPartOfSuperset)
                ListTile(
                  leading: const Icon(Icons.layers_clear),
                  title: const Text('Remove from Superset'),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      final oldSupersetId = exercise.supersetId;
                      exercise.supersetId = null;
                      exercise.supersetOrder = null;

                      // Check if only 1 exercise remains in the superset
                      final remainingInSuperset = _allExercises
                          .where((e) => e.supersetId == oldSupersetId)
                          .toList();

                      if (remainingInSuperset.length == 1) {
                        remainingInSuperset.first.supersetId = null;
                        remainingInSuperset.first.supersetOrder = null;
                      } else {
                        // Reorder remaining exercises
                        remainingInSuperset.sort(
                          (a, b) => (a.supersetOrder ?? 0).compareTo(
                            b.supersetOrder ?? 0,
                          ),
                        );
                        for (var i = 0; i < remainingInSuperset.length; i++) {
                          remainingInSuperset[i].supersetOrder = i;
                        }
                      }

                      filterExercises();
                      _saveExercises();
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Exercise',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pop();
                  _showDeleteExerciseDialog(exercise);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showDeleteExerciseDialog(Exercise exerciseToDelete) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Exercise'),
          content: Text(
            'Are you sure you want to delete "${exerciseToDelete.name}"?',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _allExercises.remove(exerciseToDelete);

                  // Clean up groups with only 1 member after deletion
                  if (exerciseToDelete.isPartOfGroup) {
                    final remainingInGroup = _allExercises
                        .where((e) => e.groupId == exerciseToDelete.groupId)
                        .toList();

                    if (remainingInGroup.length == 1) {
                      remainingInGroup.first.groupId = null;
                    }
                  }

                  filterExercises();
                  _saveExercises();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
