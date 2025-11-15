import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startStopwatchCallback() {
  FlutterForegroundTask.setTaskHandler(StopwatchTaskHandler());
}

class StopwatchTaskHandler extends TaskHandler {
  int _currentElapsedMilliseconds = 0;
  bool _notificationSent = false;
  int _timerDuration = 120;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    _notificationSent = false;
    final prefs = await SharedPreferences.getInstance();
    _timerDuration = prefs.getInt('timer_duration') ?? 120;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();
    const InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Create a channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'rest_timer_channel', // id
      'Rest Timer Notifications', // title
      description: 'Notifications for the rest timer.', // description
      importance: Importance.max,
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  @override
  void onRepeatEvent(DateTime timestamp) {
    // This event is triggered periodically, but the notification update
    // is handled by onReceiveData when the UI sends new data.
    // We can use this to ensure the service stays alive, or for other periodic tasks.
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    _notificationSent = false;
  }

  @override
  void onReceiveData(Object data) {
    if (data is Map<String, dynamic>) {
      _currentElapsedMilliseconds = data['elapsedMilliseconds'] as int;
      final String formattedTime = _formatTime(_currentElapsedMilliseconds);

      if (_currentElapsedMilliseconds >= _timerDuration * 1000 && !_notificationSent) {
        _showNotification();
        _notificationSent = true;
      }

      FlutterForegroundTask.updateService(
        notificationTitle: 'Rest Timer',
        notificationText: 'Elapsed: $formattedTime',
      );
    }
  }

  Future<void> _showNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails('rest_timer_channel', 'Rest Timer Notifications',
            channelDescription: 'Notifications for the rest timer.',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(presentSound: true, presentBadge: true, presentAlert: true);
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        0, 'Rest Timer', '$_timerDuration seconds have passed!', platformChannelSpecifics,
        payload: 'item x');
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
