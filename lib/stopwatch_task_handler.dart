import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

class StopwatchTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    // The service is started, but the stopwatch time will be sent from the UI.
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This will not be used as we are sending data from the UI.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    // Clean up any resources if needed.
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      final int elapsedMilliseconds = data['elapsedMilliseconds'];
      final String formattedTime = _formatTime(elapsedMilliseconds);

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
