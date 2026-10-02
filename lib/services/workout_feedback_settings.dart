import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutFeedbackSettings extends ChangeNotifier {
  WorkoutFeedbackSettings._();

  static final WorkoutFeedbackSettings instance = WorkoutFeedbackSettings._();

  static const _hapticsKey = 'workout_feedback_haptics_enabled';
  static const _soundKey = 'workout_feedback_sound_enabled';

  bool _hapticsEnabled = true;
  bool _soundEnabled = false;

  bool get hapticsEnabled => _hapticsEnabled;
  bool get soundEnabled => _soundEnabled;

  Future<void> init() async {
    final preferences = await SharedPreferences.getInstance();
    _hapticsEnabled = preferences.getBool(_hapticsKey) ?? true;
    _soundEnabled = preferences.getBool(_soundKey) ?? false;
    notifyListeners();
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    if (_hapticsEnabled == enabled) return;
    _hapticsEnabled = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_hapticsKey, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    if (_soundEnabled == enabled) return;
    _soundEnabled = enabled;
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_soundKey, enabled);
  }
}
