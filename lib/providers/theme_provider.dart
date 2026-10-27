import 'package:flutter/material.dart';
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode=ThemeMode.system; ThemeMode get themeMode=>_mode; bool get isDark=>_mode==ThemeMode.dark;
  void toggle(bool value){_mode=value?ThemeMode.dark:ThemeMode.light;notifyListeners();}
}
