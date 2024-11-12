import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/user.dart' as model;
import 'package:wyd_front/service/auth_service.dart';
import 'package:wyd_front/state/user_provider.dart';

class AuthenticationProvider with ChangeNotifier {
  // Make the singleton instance private and static
  static final AuthenticationProvider _instance =
      AuthenticationProvider._internal();

  BuildContext? _context;

  factory AuthenticationProvider({BuildContext? context}) {
    // Assign context only once during initialization
    if (context != null && _instance._context == null) {
      _instance._context = context;
    }
    return _instance;
  }

  // Private constructor
  AuthenticationProvider._internal() {
    _checkUserLoginStatus();

    // Listen to auth state changes and update _user accordingly
    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user == null) {
        _isBackendVerified = false;
      }
      notifyListeners();
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  bool _isBackendVerified = false;

  // Public getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  bool get isBackendVerified => _isBackendVerified;

  Future<void> _checkUserLoginStatus() async {
    _user = _auth.currentUser;
    _isLoading = true;
    if (_user != null) {
      await verifyBackendAuth();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await verifyBackendAuth();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw "Please insert a valid email";
      } else if (e.code == 'invalid-credential') {
        throw "The mail or the password provided are wrong";
      } else {
        debugPrint("Error signing in: $e");
        throw "Unexpected error, please try later";
      }
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await verifyBackendAuth();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw e.message.toString();
      } else if (e.code == 'email-already-in-use') {
        throw e.message.toString();
      } else {
        debugPrint("Error signing in: $e");
        throw "Unexpected error, please try later";
      }
    }

    try {
      await verifyBackendAuth();
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
  }

  Future<void> signOut() async {try {
      await verifyBackendAuth();
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
    await _auth.signOut();
  }

  // Method to perform backend verification
  Future<void> verifyBackendAuth() async {
    _isBackendVerified = false;
    try {
      final idToken = await _user?.getIdToken();
      if (idToken != null) {
        final response = await AuthService().verifyToken(idToken);

        if (response.statusCode == 200) {
          final userProvider = _context!.read<UserProvider>();

          model.User user = model.User.fromJson(jsonDecode(response.body));

          userProvider.updateUser(user);
          _isBackendVerified = true;
        } else {
          _isBackendVerified = false;
          debugPrint("Backend verification failed: ${response.statusCode}");
        }
      }
    } catch (e) {
      _isBackendVerified = false;
      debugPrint("Error during backend verification: $e");
    }
    notifyListeners();
  }
}
