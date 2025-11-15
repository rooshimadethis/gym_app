import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _timerController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final timerDuration = prefs.getInt('timer_duration') ?? 120;
    _timerController.text = timerDuration.toString();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    });
  }

  Future<void> _saveTimerDuration(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final timerDuration = int.tryParse(value) ?? 120;
    await prefs.setInt('timer_duration', timerDuration);
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() {
      _notificationsEnabled = value;
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _importExerciseData(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();
        
        // Basic validation to check if it's our data
        jsonDecode(content) as List;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('exercises_data', content);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Exercise data imported successfully!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing data: Invalid file format.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Import cancelled.')),
      );
    }
  }

  Future<void> _exportExerciseData(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString('exercises_data');

    if (exercisesJson == null || exercisesJson.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercise data to export.')),
      );
      return;
    }

    try {
      Uint8List bytes = utf8.encode(exercisesJson);

      final now = DateTime.now();
      final year = now.year;
      final month = now.month.toString().padLeft(2, '0');
      final day = now.day.toString().padLeft(2, '0');
      final hour = now.hour.toString().padLeft(2, '0');
      final minute = now.minute.toString().padLeft(2, '0');

      final formattedDate = '$year-$month-$day';
      final formattedTime = '$hour-$minute';
      final fileName = 'gym_app_export_${formattedDate}_$formattedTime';

      String? path = await FileSaver.instance.saveAs(
        name: fileName,
        bytes: bytes,
        ext: 'json',
        mimeType: MimeType.json,
      );

      if (path != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exported to $path'),
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                OpenFile.open(path);
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export cancelled.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error exporting data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.file_upload),
            title: const Text('Import Exercise Data'),
            onTap: () => _importExerciseData(context),
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Exercise Data'),
            onTap: () => _exportExerciseData(context),
          ),
          SwitchListTile(
            title: const Text('Enable Rest Timer Notifications'),
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
            secondary: const Icon(Icons.notifications),
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Rest Timer Notification (seconds)'),
            subtitle: TextField(
              controller: _timerController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: _saveTimerDuration,
              decoration: const InputDecoration(
                labelText: 'Duration in seconds',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
