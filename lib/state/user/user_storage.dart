import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/user.dart';

class UserStorage {
  // --- Singleton Implementation ---
  static final UserStorage _instance = UserStorage._internal();
  factory UserStorage() => _instance;
  UserStorage._internal();
  // --------------------------------

  final _userUpdateChannel = StreamController<User>();

  Stream<User> get userUpdatesChannel => _userUpdateChannel.stream;


  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON string
    await prefs.setString('user', jsonEncode(user.toJson()));
    _userUpdateChannel.sink.add(user);
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('user');

    if (jsonString == null) return null;

    final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
    return User.fromJson(jsonMap);
  }

  /// Clear all claims
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert to JSON string
    await prefs.setString('user', "");
  }
}
