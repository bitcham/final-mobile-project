import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists device-wide UI preferences that are not tied to a single user
/// row, such as the light/dark theme choice.
class SettingsService {
  static const String _darkModeKey = 'cinerate.settings.darkMode';

  /// Returns the stored dark-mode preference, or `null` when the user has
  /// never toggled it (callers fall back to their own default).
  Future<bool?> loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey);
  }

  Future<void> saveDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }
}

final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(),
);
