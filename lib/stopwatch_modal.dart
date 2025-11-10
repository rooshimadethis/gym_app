import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:gym_app/stopwatch_task_handler.dart';

class StopwatchModal extends StatefulWidget {
  const StopwatchModal({super.key});

  @override
  State<StopwatchModal> createState() => _StopwatchModalState();
}

class _StopwatchModalState extends State<StopwatchModal> {
  late Stopwatch _stopwatch;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {});
    });

    _startForegroundService();
  }

  Future<void> _startForegroundService() async {
    await FlutterForegroundTask.startService(
      serviceId: 123, // Unique ID for your service
      notificationTitle: 'Rest Timer',
      notificationText: 'Elapsed: ${_formatTime(_stopwatch.elapsedMilliseconds)}',
      callback: startStopwatchCallback,
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    FlutterForegroundTask.stopService();
    super.dispose();
  }

  String _formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).truncate();
    int minutes = (seconds / 60).truncate();
    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rest Timer'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(_stopwatch.elapsedMilliseconds),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.of(context).pop(); // Close the modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Finish Rest'),
          ),
        ],
      ),
    );
  }
}
