import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      String? path = await FileSaver.instance.saveFile(
        name: 'gym_app_export',
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
            onTap: null,
          ),
          ListTile(
            leading: const Icon(Icons.file_download),
            title: const Text('Export Exercise Data'),
            onTap: () => _exportExerciseData(context),
          ),
        ],
      ),
    );
  }
}
