import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';

import 'package:gym_app/services/rest_timer_manager.dart';
import 'package:gym_app/domain/gamification.dart';
import 'package:gym_app/services/gamification_service.dart';

class WorkoutSessionManager extends ChangeNotifier {
  static final WorkoutSessionManager _instance =
      WorkoutSessionManager._internal();
  static WorkoutSessionManager get instance => _instance;

  WorkoutSessionManager._internal();

  String? _currentSessionId;
  DateTime? _sessionStartTime;
  GamificationService? _gamification;
  bool _didRecoverAttempts = false;

  Timer? _autoEndTimer;

  static const String _prefSessionIdKey = 'current_session_id';
  static const String _prefStartTimeKey = 'current_session_start_time';

  String? get currentSessionId => _currentSessionId;
  DateTime? get sessionStartTime => _sessionStartTime;
  bool get isWorkoutActive => _currentSessionId != null;

  void configureGamification(GamificationService service) {
    _gamification = service;
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSessionId = prefs.getString(_prefSessionIdKey);
    final startTimeIso = prefs.getString(_prefStartTimeKey);
    if (startTimeIso != null) {
      _sessionStartTime = DateTime.tryParse(startTimeIso);
    }
    if (!_didRecoverAttempts && _gamification != null) {
      await _gamification!.recoverUnfinishedAttempts();
      _didRecoverAttempts = true;
    }
    if (_currentSessionId != null && _sessionStartTime != null) {
      await _gamification?.startSession(
        sessionId: _currentSessionId,
        startedAt: _sessionStartTime,
      );
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
        await endWorkout(reason: WorkoutEndReason.automatic);
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
        endWorkout(reason: WorkoutEndReason.automatic);
      } else {
        _autoEndTimer = Timer(remaining, () {
          endWorkout(reason: WorkoutEndReason.automatic);
        });
      }
    }
  }

  Future<void> startWorkout() async {
    if (isWorkoutActive) return;

    final sessionId = const Uuid().v4();
    final startedAt = DateTime.now();

    await _gamification?.startSession(
      sessionId: sessionId,
      startedAt: startedAt,
    );

    _currentSessionId = sessionId;
    _sessionStartTime = startedAt;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefSessionIdKey, _currentSessionId!);
    await prefs.setString(
      _prefStartTimeKey,
      _sessionStartTime!.toIso8601String(),
    );
    _startAutoEndTimer();
    notifyListeners();
  }

  Future<String?> endWorkout({
    WorkoutEndReason reason = WorkoutEndReason.explicit,
  }) async {
    final endedSessionId = _currentSessionId;
    if (endedSessionId == null) return null;

    await _gamification?.completeWorkout(endedSessionId, reason: reason);

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
    return endedSessionId;
  }
}
