import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';
  static const String _keyUserPhone = 'userPhone';
  static const String _keyLoggedIn = 'loggedIn'; // New key for login status

  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance(); // Initialize only once
  }

  static Future<void> saveUser({
    required String userId,
    required String userName,
    required String userEmail,
    required String userPhone,
  }) async {
    await init();
    await _prefs?.setString(_keyUserId, userId);
    await _prefs?.setString(_keyUserName, userName);
    await _prefs?.setString(_keyUserEmail, userEmail);
    await _prefs?.setString(_keyUserPhone, userPhone);
    await _prefs?.setBool(_keyLoggedIn, true); // Set login status to true
  }

  static Future<Map<String, String?>> getUser() async {
    await init();
    final userId = _prefs?.getString(_keyUserId);
    final userName = _prefs?.getString(_keyUserName);
    final userEmail = _prefs?.getString(_keyUserEmail);
    final userPhone = _prefs?.getString(_keyUserPhone);
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userPhone': userPhone,
    };
  }

  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs?.getString(_keyUserId) != null;
  }

  static Future<void> clearUser() async {
    await init();
    await _prefs?.clear();
  }
}
