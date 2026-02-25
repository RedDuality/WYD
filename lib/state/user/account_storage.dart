import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/users/account.dart';

class AccountStorage {
  // --- Singleton Implementation ---
  static final AccountStorage _instance = AccountStorage._internal();
  factory AccountStorage() => _instance;
  AccountStorage._internal();
  // --------------------------------

  Future<SharedPreferences>? _prefsFuture;

  Future<SharedPreferences> get _prefs {
    return _prefsFuture ??= SharedPreferences.getInstance();
  }

  Set<Account> accounts = {};

  Future<void> saveAccounts(Set<Account> accounts) async {
    this.accounts = accounts;

    final prefs = await _prefs;
    final List<Map<String, dynamic>> jsonList = accounts.map((a) => a.toJson()).toList();
    await prefs.setString('accounts', jsonEncode(jsonList));
  }

  Future<Set<Account>> getAccounts() async {
    if (accounts.isNotEmpty) return accounts;

    final prefs = await _prefs;
    final jsonString = prefs.getString('accounts');

    if (jsonString == null || jsonString.isEmpty) return {};

    final List<dynamic> decodedList = jsonDecode(jsonString);
    return decodedList.map((item) => Account.fromJson(item as Map<String, dynamic>)).toSet();
  }

  Future<void> clearAll() async {
    accounts = {};
    final prefs = await _prefs;
    await prefs.remove('accounts');
  }
}
