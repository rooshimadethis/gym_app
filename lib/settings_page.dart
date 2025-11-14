import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
            onTap: null,
          ),
        ],
      ),
    );
  }
}
