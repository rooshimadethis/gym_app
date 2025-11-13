import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'dart:convert';
import 'package:animations/animations.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/exercise_detail_view.dart';
import 'package:gym_app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          primary: Color(0xFFF57C00),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB74D),
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
          primary: Color(0xFFF57C00),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB74D),
          onSecondary: Color(0xFF212121),
          error: Colors.red,
          onError: Colors.white,
          surface: Color(0xFF121212),
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

  void filterExercises() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredExercises = _allExercises
          .where((exercise) => exercise.name.toLowerCase().contains(query))
          .toList();
    });
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
    super.dispose();
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
              onPressed: () {
                final newExerciseName = newExerciseController.text;
                if (newExerciseName.isNotEmpty) {
                  setState(() async {
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
                    _allExercises.add(newExercise);
                    filterExercises();
                    _saveExercises();
                  });
                  Navigator.of(context).pop();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.title,
          style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
        ),
        actions: [
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
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final placeHolderImageUrl =
                    'https://placehold.co/400x200.png?text=${Uri.encodeComponent(exercise.name)}';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: GestureDetector(
                    onLongPress: () {
                      _showDeleteExerciseDialog(exercise);
                    },
                    child: OpenContainer(
                      tappable: false,
                      closedColor: Theme.of(context).colorScheme.primary,
                      closedShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      closedElevation: 0.0,
                      transitionDuration: const Duration(milliseconds: 300),
                      openBuilder: (context, action) {
                        return ExerciseDetailView(exercise: exercise);
                      },
                      onClosed: (_) => _saveExercises(),
                      closedBuilder: (context, action) {
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            action();
                          },
                          child: AspectRatio(
                            aspectRatio:
                                2 /
                                1, // Changed to 2:1 aspect ratio for shorter cards
                            child: Card(
                              elevation: 0,
                              color: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Expanded(
                                    child:
                                        exercise.hasLocalImage &&
                                            exercise.imageUrl != null
                                        ? Image.asset(
                                            exercise.imageUrl!,
                                            fit: BoxFit
                                                .contain, // Changed to contain
                                            width: double.infinity,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl: placeHolderImageUrl,
                                            fit: BoxFit
                                                .contain, // Changed to contain
                                            width: double.infinity,
                                            placeholder: (context, url) =>
                                                Container(
                                                  color: Colors.grey[300],
                                                ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    const Icon(Icons.error),
                                          ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Text(
                                      exercise.name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onPrimary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
                setState(() {
                  _allExercises.remove(exerciseToDelete);
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
