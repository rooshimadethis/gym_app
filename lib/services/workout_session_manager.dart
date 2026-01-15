import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'package:gym_app/services/rest_timer_manager.dart';

class WorkoutSessionManager extends ChangeNotifier {
  static final WorkoutSessionManager _instance =
      WorkoutSessionManager._internal();
  static WorkoutSessionManager get instance => _instance;

  WorkoutSessionManager._internal();

  String? _currentSessionId;
  DateTime? _sessionStartTime;

  Timer? _autoEndTimer;

  static const String _prefSessionIdKey = 'current_session_id';
  static const String _prefStartTimeKey = 'current_session_start_time';

  String? get currentSessionId => _currentSessionId;
  bool get isWorkoutActive => _currentSessionId != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSessionId = prefs.getString(_prefSessionIdKey);
    final startTimeIso = prefs.getString(_prefStartTimeKey);
    if (startTimeIso != null) {
      _sessionStartTime = DateTime.tryParse(startTimeIso);
    }
    await _checkAutoEnd();
    if (isWorkoutActive) {
      _startAutoEndTimer();
    }
  }

  Future<void> _checkAutoEnd() async {
    if (_sessionStartTime != null) {
      final difference = DateTime.now().difference(_sessionStartTime!);
      if (difference.inHours >= 4) {
        await endWorkout();
      }
    }
  }

  void _startAutoEndTimer() {
    _autoEndTimer?.cancel();
    if (_sessionStartTime != null) {
      final now = DateTime.now();
      final difference = now.difference(_sessionStartTime!);
      final remaining = const Duration(hours: 4) - difference;

      if (remaining.isNegative) {
        endWorkout();
      } else {
        _autoEndTimer = Timer(remaining, () {
          endWorkout();
        });
      }
    }
  }

  Future<void> startWorkout() async {
    if (isWorkoutActive) return;

    _currentSessionId = const Uuid().v4();
    _sessionStartTime = DateTime.now();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSessionIdKey, _currentSessionId!);
    await prefs.setString(
      _prefStartTimeKey,
      _sessionStartTime!.toIso8601String(),
    );
    _startAutoEndTimer();
    notifyListeners();
  }

  Future<void> endWorkout() async {
    _autoEndTimer?.cancel();
    _autoEndTimer = null;

    // Stop the rest timer and foreground service if running
    RestTimerManager.instance.stop();

    _currentSessionId = null;
    _sessionStartTime = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefSessionIdKey);
    await prefs.remove(_prefStartTimeKey);
    notifyListeners();
  }
}
