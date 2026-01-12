import 'dart:convert';
import 'dart:io';

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
  bool _warmupSetEnabled = false;

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
      _warmupSetEnabled = prefs.getBool('warmup_set_enabled') ?? false;
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

  Future<void> _saveWarmupSetSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('warmup_set_enabled', value);
    setState(() {
      _warmupSetEnabled = value;
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _importExerciseData() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        final data = jsonDecode(content) as Map<String, dynamic>;
        final exercises = data['exercises_data'] as List;
        final settings = data['settings'] as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('exercises_data', jsonEncode(exercises));
        await prefs.setInt('timer_duration', settings['timer_duration']);
        await prefs.setBool(
          'notifications_enabled',
          settings['notifications_enabled'],
        );
        if (settings.containsKey('warmup_set_enabled')) {
          await prefs.setBool(
            'warmup_set_enabled',
            settings['warmup_set_enabled'],
          );
        }

        _loadSettings();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data imported successfully!')),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing data: Invalid file format.')),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Import cancelled.')));
    }
  }

  Future<void> _exportExerciseData() async {
    final prefs = await SharedPreferences.getInstance();
    final exercisesJson = prefs.getString('exercises_data');
    final timerDuration = prefs.getInt('timer_duration') ?? 120;
    final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final warmupSetEnabled = prefs.getBool('warmup_set_enabled') ?? false;

    if (exercisesJson == null || exercisesJson.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No exercise data to export.')),
      );
      return;
    }

    final data = {
      'exercises_data': jsonDecode(exercisesJson),
      'settings': {
        'timer_duration': timerDuration,
        'notifications_enabled': notificationsEnabled,
        'warmup_set_enabled': warmupSetEnabled,
      },
    };

    try {
      Uint8List bytes = utf8.encode(jsonEncode(data));

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
        if (!mounted) return;
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
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Export cancelled.')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error exporting data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          _buildSectionHeader('Data Management'),
          _buildSettingTile(
            icon: Icons.file_upload_outlined,
            title: 'Import Exercise Data',
            onTap: _importExerciseData,
          ),
          _buildSettingTile(
            icon: Icons.file_download_outlined,
            title: 'Export Exercise Data',
            onTap: _exportExerciseData,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Preferences'),
          SwitchListTile(
            title: const Text(
              'Notifications',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Rest timer background alerts'),
            value: _notificationsEnabled,
            onChanged: _saveNotificationSetting,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text(
              'Warmup Set',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Skip auto-fill for the first set'),
            value: _warmupSetEnabled,
            onChanged: _saveWarmupSetSetting,
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.fitness_center_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Timer Configuration'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.timer_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Rest Duration (seconds)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: _timerController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: _saveTimerDuration,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      isDense: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white70),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: Colors.white24,
      ),
      onTap: onTap,
    );
  }
}
