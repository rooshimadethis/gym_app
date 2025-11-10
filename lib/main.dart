import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gym_app/exercise_detail_view.dart';
import 'package:gym_app/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gym App',
      theme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: Color(0xFFF57C00),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB74D),
          onSecondary: Color(0xFF212121),
          error: Colors.red,
          onError: Colors.white,
          background: Color(0xFFFAFAFA),
          onBackground: Color(0xFF212121),
          surface: Colors.white,
          onSurface: Color(0xFF212121),
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFF57C00),
          onPrimary: Colors.white,
          secondary: Color(0xFFFFB74D),
          onSecondary: Color(0xFF212121),
          error: Colors.red,
          onError: Colors.white,
          background: Color(0xFF121212),
          onBackground: Colors.white,
          surface: Color(0xFF1E1E1E),
          onSurface: Colors.white,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(title: 'Gym App'),
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
        Exercise(name: 'Push-ups'),
        Exercise(name: 'Pull-ups'),
        Exercise(name: 'Squats'),
        Exercise(name: 'Deadlifts'),
        Exercise(name: 'Bench Press'),
        Exercise(name: 'Overhead Press'),
        Exercise(name: 'Rows'),
        Exercise(name: 'Curls'),
        Exercise(name: 'Tricep Extensions'),
        Exercise(name: 'Lunges'),
      ];
    } else {
      final exercisesList = jsonDecode(exercisesJson) as List;
      _allExercises =
          exercisesList.map((json) => Exercise.fromJson(json)).toList();
    }
    filterExercises();
  }

  Future<void> _saveExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson =
        jsonEncode(_allExercises.map((e) => e.toJson()).toList());
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
                  setState(() {
                    _allExercises.add(Exercise(name: newExerciseName));
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title,
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary)),
        actions: [
          IconButton(
            icon:
                Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
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
                  borderSide:
                      BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredExercises.length,
              itemBuilder: (context, index) {
                final exercise = _filteredExercises[index];
                final imageUrl =
                    'https://placehold.co/400x200.png?text=${exercise.name}';
                return InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailView(
                          exercise: exercise,
                        ),
                      ),
                    );
                    _saveExercises();
                  },
                  onLongPress: () {
                    _showDeleteExerciseDialog(exercise);
                  },
                  child: Card(
                    elevation: 10.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2.0, // Adjust border width as needed
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          placeholder: (context, url) =>
                              const Center(child: CircularProgressIndicator()),
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            exercise.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
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
          content:
              Text('Are you sure you want to delete "${exerciseToDelete.name}"?'),
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
