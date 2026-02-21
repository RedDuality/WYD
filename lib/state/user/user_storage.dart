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

  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Future<void> saveUser(User user) async {
    final prefs = await _prefs;

    await prefs.setString('user', jsonEncode(user.toJson()));
    UserCache().updateUser(user);
  }

  Future<User?> getUser() async {
    final prefs = await _prefs;
    final jsonString = prefs.getString('user');

    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return User.fromJson(jsonMap);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;

    await prefs.remove('user');
  }
}
