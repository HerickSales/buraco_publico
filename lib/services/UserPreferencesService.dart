import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService {
  static const String _userDataKey = 'user_data';

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    String userDataJson = json.encode(userData);
    await prefs.setString(_userDataKey, userDataJson);
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String? userDataJson = prefs.getString(_userDataKey);
    if (userDataJson == null) return null;
    return json.decode(userDataJson);
  }

  Future<void> deleteUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
  }
}
