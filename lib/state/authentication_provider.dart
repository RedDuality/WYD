import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/user.dart' as model;
import 'package:wyd_front/API/auth_api.dart';
import 'package:wyd_front/state/user_provider.dart';

class AuthenticationProvider with ChangeNotifier {
  // Make the singleton instance private and static
  static final AuthenticationProvider _instance =
      AuthenticationProvider._internal();

  factory AuthenticationProvider({BuildContext? context}) {
    return _instance;
  }

  // Private constructor
  AuthenticationProvider._internal() {
    _checkUserLoginStatus();

    _auth.authStateChanges().listen((User? user) async {
      _user = user;
      if (_user == null) {
        _isBackendVerified = false;
        notifyListeners();
      }
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  bool _isBackendVerified = false;

  // Public getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isBackendVerified => _isBackendVerified;

  Future<void> _checkUserLoginStatus() async {
    _isLoading = true;
    _isBackendVerified = false;
    _user = _auth.currentUser;
    if (_user != null) {
      try {
        await verifyBackendAuth();
      } catch (e) {
        //_isLoading = false;
      }
    }
    _isLoading = false;
    notifyListeners(); //scatena un cambio di route a '/'
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await verifyBackendAuth();
      notifyListeners();
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
      notifyListeners();
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Method to perform backend verification
  Future<void> verifyBackendAuth() async {
    model.User? user;
    try {
      final idToken = await _user?.getIdToken();
      if (idToken != null) {
        final response = await AuthAPI().verifyToken(idToken);

        if (response.statusCode == 200) {
          user = model.User.fromJson(jsonDecode(response.body));
          _isBackendVerified = true;
        } else {
          throw "Server verification failed: ${response.statusCode}";
        }
      } else {
        throw "Token null";
      }
    } catch (e) {
      throw "Error during server verification: ${e.toString()}";
    }

    final userProvider = UserProvider();
    userProvider.updateUser(user);
  }
}
