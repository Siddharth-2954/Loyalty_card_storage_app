import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userId;
  String? _email;

  bool get isAuthenticated => _isAuthenticated;
  String? get userId => _userId;
  String? get email => _email;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('is_authenticated') ?? false;
    _userId = prefs.getString('user_id');
    _email = prefs.getString('email');
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      // TODO: Implement actual authentication logic
      _isAuthenticated = true;
      _userId = 'user123'; // Replace with actual user ID
      _email = email;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_authenticated', true);
      await prefs.setString('user_id', _userId!);
      await prefs.setString('email', email);

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      _isAuthenticated = false;
      _userId = null;
      _email = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('is_authenticated');
      await prefs.remove('user_id');
      await prefs.remove('email');

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
