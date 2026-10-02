import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeManager with ChangeNotifier {
  static final ThemeManager instance = ThemeManager._internal();
  ThemeManager._internal();

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex =
        prefs.getInt('theme_mode') ??
        2; // Default to dark as requested/current behavior
    if (themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.dark;
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }
}
