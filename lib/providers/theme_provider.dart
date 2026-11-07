import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _preferenceKey = 'campus_incident_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  bool _isLoaded = false;

  ThemeMode get themeMode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      _mode = switch (preferences.getString(_preferenceKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {
      // The system theme remains a safe fallback if local storage is unavailable.
      _mode = ThemeMode.system;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  void toggle(bool value) {
    final nextMode = value ? ThemeMode.dark : ThemeMode.light;
    if (_mode == nextMode) return;
    _mode = nextMode;
    notifyListeners();
    unawaited(_save(nextMode));
  }

  Future<void> _save(ThemeMode mode) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(
        _preferenceKey,
        mode == ThemeMode.dark ? 'dark' : 'light',
      );
    } catch (_) {
      // A storage failure must not prevent the current session from changing theme.
    }
  }
}