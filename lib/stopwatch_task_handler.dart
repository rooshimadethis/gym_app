import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

class StopwatchTaskHandler extends TaskHandler {
  int _currentElapsedMilliseconds = 0;

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // No internal stopwatch needed, time will be received from UI.
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This event is triggered periodically, but the notification update
    // is handled by onReceiveData when the UI sends new data.
    // We can use this to ensure the service stays alive, or for other periodic tasks.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // No internal stopwatch to stop.
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      _currentElapsedMilliseconds = data['elapsedMilliseconds'] as int;
      final String formattedTime = _formatTime(_currentElapsedMilliseconds);

      FlutterForegroundTask.updateService(
        notificationTitle: 'Rest Timer',
        notificationText: 'Elapsed: $formattedTime',
      );
    }
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
