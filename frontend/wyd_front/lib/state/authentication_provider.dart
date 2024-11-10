import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/user.dart' as model;
import 'package:wyd_front/service/auth_service.dart';

class AuthenticationProvider with ChangeNotifier {
  // Make the singleton instance private and static
  static final AuthenticationProvider _instance = AuthenticationProvider._internal();

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

  // Factory constructor returns the singleton instance
  factory AuthenticationProvider() {
    return _instance;
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
        throw Exception("Please insert a valid email");
      } else if (e.code == 'invalid-credential') {
        throw Exception("The mail or the password provided are wrong");
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
  }

  Future<void> signOut() async {
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
          _isBackendVerified = true;
          model.User user = model.User.fromJson(jsonDecode(response.body));
          
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
