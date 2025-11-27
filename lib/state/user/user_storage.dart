import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/users/user.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class UserStorage {
  // --- Singleton Implementation ---
  static final UserStorage _instance = UserStorage._internal();
  factory UserStorage() => _instance;
  UserStorage._internal();
  // --------------------------------

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON string
    await prefs.setString('user', jsonEncode(user.toJson()));
    UserCache().updateUser(user);
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');

    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return User.fromJson(jsonMap);
  }

  Future<void> clearAll() async {
    UserCache().updateUser(null);
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON string
    await prefs.setString('user', "");
  }
}
