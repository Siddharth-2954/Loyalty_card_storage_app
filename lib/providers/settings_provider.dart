import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _cardViewMode = 'grid'; // 'grid' or 'list'
  bool _notificationsEnabled = true;
  bool _useBiometrics = false;

  ThemeMode get themeMode => _themeMode;
  String get cardViewMode => _cardViewMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get useBiometrics => _useBiometrics;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _themeMode = ThemeMode.values[prefs.getInt('theme_mode') ?? 0];
    _cardViewMode = prefs.getString('card_view_mode') ?? 'grid';
    _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    _useBiometrics = prefs.getBool('use_biometrics') ?? false;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', mode.index);
    notifyListeners();
  }

  Future<void> setCardViewMode(String mode) async {
    _cardViewMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('card_view_mode', mode);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
    notifyListeners();
  }

  Future<void> toggleBiometrics(bool enabled) async {
    _useBiometrics = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_biometrics', enabled);
    notifyListeners();
  }
}
