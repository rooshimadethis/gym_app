import 'dart:convert';
import 'package:gym_app/models/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Update only this exercise's preference, preserving the rest of the list.
Future<void> saveExerciseWarmup(Exercise exercise, bool enabled) async {
  final prefs = await SharedPreferences.getInstance();
  final rows = (jsonDecode(prefs.getString('exercises_data') ?? '[]') as List)
      .map((row) => Map<String, dynamic>.from(row as Map))
      .toList();
  final matches = rows.where((row) => row['id'] == exercise.id);
  if (matches.length != 1) throw StateError('Exercise is not saved.');
  matches.single['warmupSetEnabled'] = enabled;
  if (!await prefs.setString('exercises_data', jsonEncode(rows))) {
    throw StateError('Could not save warmup preference.');
  }
  exercise.warmupSetEnabled = enabled;
}
