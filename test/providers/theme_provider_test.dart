import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:campus_incident_reporter/providers/theme_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('uses the system theme when no preference has been saved', () async {
    final provider = ThemeProvider();

    await provider.load();

    expect(provider.themeMode, ThemeMode.system);
    expect(provider.isLoaded, isTrue);
    provider.dispose();
  });

  test('restores a saved dark theme', () async {
    SharedPreferences.setMockInitialValues({
      'campus_incident_theme_mode': 'dark',
    });
    final provider = ThemeProvider();

    await provider.load();

    expect(provider.themeMode, ThemeMode.dark);
    expect(provider.isDark, isTrue);
    provider.dispose();
  });

  test('persists a changed theme preference', () async {
    final provider = ThemeProvider();
    await provider.load();

    provider.toggle(true);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('campus_incident_theme_mode'), 'dark');
    provider.dispose();
  });
}