// lib/core/repositories/theme_repository.dart
import 'package:shared_preferences/shared_preferences.dart';

class ThemeRepository {
  static const _themeKey = 'theme_mode';

  Future<String?> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey);
  }

  Future<void> saveThemeMode(String themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode);
  }
}