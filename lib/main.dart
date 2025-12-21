import 'dart:async';
import 'package:gym_app/exercise_card.dart';
import 'package:gym_app/alternative_exercise_group.dart';
import 'package:gym_app/superset_exercise_group.dart';
import 'package:gym_app/exercise_detail_view.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/settings_page.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gym_app/stopwatch_task_handler.dart';

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rooshi\'s get swole',
      theme: ThemeData(
        fontFamily: 'StackSansText',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFF4C763B),
          onPrimary: Colors.white,
          secondary: Color(0xFF77A26D),
          onSecondary: Color(0xFF212121),
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFFFAFAFA),
          onSurface: Color(0xFF212121),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        fontFamily: 'StackSansText',
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFF4C763B),
          onPrimary: Colors.white,
          secondary: Color(0xFF77A26D),
          onSecondary: Color(0xFF212121),
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF212121),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'rooshi\'s get swole'),
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
  final Stopwatch _workoutStopwatch = Stopwatch();
  Timer? _workoutTimer;
  bool _isWorkoutTimerRunning = false;
  Map<String, int> _supersetProgress =
      {}; // Track current position in each superset

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
    _loadExercises();
    _loadSupersetProgress();
    _searchController.addListener(() {
      filterExercises();
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
      _allExercises = exercisesList
          .map((json) => Exercise.fromJson(json))
          .toList();
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
    filterExercises();
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
    return _filteredExercises.where((e) => e.supersetId == supersetId).toList()
      ..sort((a, b) => (a.supersetOrder ?? 0).compareTo(b.supersetOrder ?? 0));
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

        // Remove all from list
        _allExercises.removeWhere((e) => e.groupId == exercise.groupId);

        // Add all to bottom
        _allExercises.addAll(groupExercises);
      } else {
        // Single exercise
        _allExercises.remove(exercise);
        _allExercises.add(exercise);
      }
      filterExercises();
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
    _searchController.dispose();
    _workoutTimer?.cancel();
    super.dispose();
  }

  void _startWorkoutTimer() {
    setState(() {
      _isWorkoutTimerRunning = true;
    });
    _workoutStopwatch.start();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });
  }

  void _stopWorkoutTimer() {
    setState(() {
      _isWorkoutTimerRunning = false;
    });
    _workoutStopwatch.stop();
    _workoutStopwatch.reset();
    _workoutTimer?.cancel();
  }

  String _formatWorkoutTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  Future<void> _showAddExerciseDialog() async {
    final TextEditingController newExerciseController = TextEditingController();
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Exercise'),
          content: TextField(
            controller: newExerciseController,
            decoration: const InputDecoration(hintText: "Exercise Name"),
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
                final newExerciseName = newExerciseController.text;
                if (newExerciseName.isNotEmpty) {
                  final newExercise = Exercise(name: newExerciseName);
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
          backgroundColor: const Color(0xFF212121),
          title: Text(
            widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          actions: [
            if (_isWorkoutTimerRunning)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    _formatWorkoutTime(_workoutStopwatch.elapsedMilliseconds),
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            IconButton(
              icon: Icon(
                Icons.settings,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
                _loadExercises();
              },
            ),
            IconButton(
              icon: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              onPressed: _showAddExerciseDialog,
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search',
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _getDisplayGroups().length,
                itemBuilder: (context, index) {
                  final group = _getDisplayGroups()[index];

                  // Check if this is a superset
                  if (group.isNotEmpty && group[0].isPartOfSuperset) {
                    final supersetId = group[0].supersetId!;
                    return SupersetExerciseGroup(
                      key: ObjectKey(supersetId),
                      supersetExercises: group,
                      onExerciseCompleted: (exercise) {
                        _moveExerciseToBottom(exercise);
                        _workoutStopwatch.reset();
                        if (!_isWorkoutTimerRunning) {
                          _startWorkoutTimer();
                        }
                      },
                      onLongPress: (exercise) =>
                          _showExerciseOptionsDialog(exercise),
                      onTap: () => _stopWorkoutTimer(),
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
                    // Single exercise - render as before
                    final exercise = group[0];
                    return Padding(
                      key: ObjectKey(exercise),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: 16.0,
                      ),
                      child: ExerciseCard(
                        exercise: exercise,
                        onExerciseCompleted: () {
                          _moveExerciseToBottom(exercise);
                          _workoutStopwatch.reset();
                          if (!_isWorkoutTimerRunning) {
                            _startWorkoutTimer();
                          }
                        },
                        onLongPress: () => _showExerciseOptionsDialog(exercise),
                        onTap: () => _stopWorkoutTimer(),
                      ),
                    );
                  } else {
                    // Alternative group - render horizontal scroll
                    return Padding(
                      key: ObjectKey(group[0].groupId),
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: AlternativeExerciseGroup(
                        alternatives: group,
                        onExerciseCompleted: (exercise) {
                          _moveExerciseToBottom(exercise);
                          _workoutStopwatch.reset();
                          if (!_isWorkoutTimerRunning) {
                            _startWorkoutTimer();
                          }
                        },
                        onLongPress: (exercise) =>
                            _showExerciseOptionsDialog(exercise),
                        onTap: () => _stopWorkoutTimer(),
                      ),
                    );
                  }
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
