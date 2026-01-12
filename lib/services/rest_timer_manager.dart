import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/services/stopwatch_task_handler.dart';

class RestTimerManager extends ChangeNotifier {
  static final RestTimerManager _instance = RestTimerManager._internal();
  static RestTimerManager get instance => _instance;

  RestTimerManager._internal();

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  bool _isActive = false;
  int _timerDuration = 120;

  bool get isActive => _isActive;
  int get elapsedMilliseconds => _stopwatch.elapsedMilliseconds;
  int get timerDuration => _timerDuration;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _timerDuration = prefs.getInt('timer_duration') ?? 120;
  }

  void start() {
    if (_isActive) {
      _stopwatch.stop();
      _stopwatch.reset();
    }
    _isActive = true;
    _stopwatch.start();
    _startTimer();
    _startForegroundService();
    notifyListeners();
  }

  void stop() {
    _isActive = false;
    _stopwatch.stop();
    _stopwatch.reset();
    _timer?.cancel();
    FlutterForegroundTask.stopService();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isActive) {
        FlutterForegroundTask.sendDataToTask({
          'elapsedMilliseconds': _stopwatch.elapsedMilliseconds,
        });
        notifyListeners();
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _startForegroundService() async {
    await FlutterForegroundTask.startService(
      serviceId: 123,
      notificationTitle: 'Rest Timer',
      notificationText:
          'Elapsed: ${_formatTime(_stopwatch.elapsedMilliseconds)}',
      callback: startStopwatchCallback,
    );
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }
}
