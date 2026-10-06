import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:gym_app/main.dart'; // for db access
import 'package:gym_app/services/theme_manager.dart';
import 'package:gym_app/services/workout_feedback_settings.dart';
import 'package:gym_app/services/backup_service.dart';
import 'package:gym_app/services/workout_session_manager.dart';
import 'package:gym_app/services/rest_timer_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _timerController = TextEditingController();
  bool _notificationsEnabled = true;
  bool _warmupSetEnabled = false;
  bool _workoutHapticsEnabled = true;
  bool _workoutSoundEnabled = false;
  bool _backupBusy = false;

  Future<void> _runBackupAction(Future<void> Function() action) async {
    if (_backupBusy) return;
    setState(() => _backupBusy = true);
    try {
      await action();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not access the backup file. Please try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

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
      _workoutHapticsEnabled = WorkoutFeedbackSettings.instance.hapticsEnabled;
      _workoutSoundEnabled = WorkoutFeedbackSettings.instance.soundEnabled;
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

  Future<void> _saveWorkoutHapticsSetting(bool value) async {
    await WorkoutFeedbackSettings.instance.setHapticsEnabled(value);
    if (mounted) setState(() => _workoutHapticsEnabled = value);
  }

  Future<void> _saveWorkoutSoundSetting(bool value) async {
    await WorkoutFeedbackSettings.instance.setSoundEnabled(value);
    if (mounted) setState(() => _workoutSoundEnabled = value);
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  Future<void> _importExerciseData() async {
    if (WorkoutSessionManager.instance.isWorkoutActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Finish your workout before restoring a backup.'),
        ),
      );
      return;
    }
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String content = await file.readAsString();

        final backup = WorkoutBackup.parse(content);

        if (mounted) {
          // Confirmation is read-only; persistence starts only after approval.
          final shouldImport = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Restore backup?'),
              scrollable: true,
              content: Text(
                '${backup.exercises.length} exercises · ${backup.history.length} logged sets\n'
                '${backup.sessions.length} workouts · ${backup.events.fold<int>(0, (total, event) => total + event.xpAmount)} XP\n\n'
                'This replaces your exercises, history, XP, sessions, and settings. Export your current data first if you want to keep it.\n\n'
                '${backup.isLegacy ? 'This older export has no XP/session records; those will be reset.\n\n' : ''}'
                'Unfinished workouts restore as ended attempts, with earned XP kept.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false), // Cancel
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Replace & restore',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );

          if (shouldImport == true) {
            final prefs = await SharedPreferences.getInstance();
            await BackupService(db, prefs).restore(backup);
            await ThemeManager.instance.init();
            await WorkoutFeedbackSettings.instance.init();
            await RestTimerManager.instance.init();
            await WorkoutSessionManager.instance.init();
            if (!mounted) return;
            await _loadSettings();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup restored successfully.')),
              );
            }
          }
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e is FormatException
                  ? e.message
                  : 'Restore could not finish. Reopen the app and check your data before trying again.',
            ),
            backgroundColor: Colors.red,
          ),
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

    try {
      final jsonString = await BackupService(db, prefs).export();
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

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
        fileExtension: 'json',
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
    return ListenableBuilder(
      listenable: ThemeManager.instance,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Settings'), centerTitle: true),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            children: [
              _buildSectionHeader('Appearance'),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    selectedBackgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary,
                    selectedForegroundColor: Theme.of(
                      context,
                    ).colorScheme.onPrimary,
                  ),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_outlined),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_outlined),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_outlined),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {ThemeManager.instance.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    ThemeManager.instance.setThemeMode(newSelection.first);
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Workout Feedback'),
              SwitchListTile(
                title: const Text(
                  'Haptics',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Tactile feedback for workout rewards'),
                value: _workoutHapticsEnabled,
                onChanged: _saveWorkoutHapticsSetting,
                secondary: Icon(
                  Icons.vibration,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              SwitchListTile(
                title: const Text(
                  'Celebration Sounds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Optional sounds for workout milestones'),
                value: _workoutSoundEnabled,
                onChanged: _saveWorkoutSoundSetting,
                secondary: Icon(
                  Icons.volume_up_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildSectionHeader('Data Management'),
              _buildSettingTile(
                icon: Icons.file_upload_outlined,
                title: 'Restore backup',
                onTap: () => _runBackupAction(_importExerciseData),
              ),
              _buildSettingTile(
                icon: Icons.file_download_outlined,
                title: 'Export complete backup',
                onTap: () => _runBackupAction(_exportExerciseData),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _saveTimerDuration,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
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
      },
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
