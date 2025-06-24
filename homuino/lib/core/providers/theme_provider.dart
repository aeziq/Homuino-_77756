// lib/core/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homuino/core/providers/theme_repository.dart';

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository();
});

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  final repository = ref.read(themeRepositoryProvider);
  return ThemeNotifier(repository);
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  final ThemeRepository _repository;

  ThemeNotifier(this._repository) : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final themeMode = await _repository.getThemeMode();
    if (themeMode == 'dark') {
      state = ThemeMode.dark;
    } else if (themeMode == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  void toggleTheme(bool isDark) {
    state = isDark ? ThemeMode.dark : ThemeMode.light;
    _repository.saveThemeMode(isDark ? 'dark' : 'light');
  }

  void setSystemTheme() {
    state = ThemeMode.system;
    _repository.saveThemeMode('system');
  }
}