import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; 

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme() async {
    _themeMode = (_themeMode == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);

    notifyListeners(); 
  }

  void _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isDark = prefs.getBool('isDarkMode');
    _themeMode = (isDark != null && isDark) ? ThemeMode.dark : ThemeMode.light;

    notifyListeners(); 
  }
}

