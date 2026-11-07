import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _preferenceKey = 'campus_incident_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  bool _isLoaded = false;
  bool _userChangedMode = false;
  Future<void> _saveQueue = Future<void>.value();

  ThemeMode get themeMode => _mode;
  bool get isDark => _mode == ThemeMode.dark;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      final savedMode = switch (preferences.getString(_preferenceKey)) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      // Do not let a late disk read undo a change made while loading.
      if (!_userChangedMode) _mode = savedMode;
    } catch (_) {
      // The system theme remains a safe fallback if local storage is unavailable.
      if (!_userChangedMode) _mode = ThemeMode.system;
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  void toggle(bool value) {
    final nextMode = value ? ThemeMode.dark : ThemeMode.light;
    if (_mode == nextMode) return;
    _userChangedMode = true;
    _mode = nextMode;
    notifyListeners();

    // Serialize preference writes so a slower older write cannot overwrite
    // the user's most recent theme selection.
    _saveQueue = _saveQueue.then((_) => _save(nextMode));
    unawaited(_saveQueue);
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