import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

class StopwatchTaskHandler extends TaskHandler {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _stopwatch = Stopwatch();
    _stopwatch.start();
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    final String formattedTime = _formatTime(_stopwatch.elapsedMilliseconds);
    FlutterForegroundTask.updateService(
      notificationTitle: 'Rest Timer',
      notificationText: 'Elapsed: $formattedTime',
    );
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _stopwatch.stop();
    _timer.cancel();
  }

  @override
  void onNotificationButtonPressed(String id) {
    // Handle notification button presses if any.
  }

  @override
  void onNotificationPressed() {
    // Handle notification pressed if any.
  }

  @override
  void onNotificationDismissed() {
    // Handle notification dismissed if any.
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }
}
