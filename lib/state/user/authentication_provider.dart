import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/service/model/user_service.dart';

class AuthenticationProvider with ChangeNotifier {
  static final AuthenticationProvider _instance = AuthenticationProvider._internal();

  factory AuthenticationProvider({BuildContext? context}) {
    return _instance;
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = true;
  bool _isBackendVerified = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isBackendVerified => _isBackendVerified;

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

  Future<void> _checkUserLoginStatus() async {
    _isLoading = true;
    _isBackendVerified = false;
    _user = _auth.currentUser;
    if (_user != null) {
      try {
        await retrieveBackendUser();
      } catch (e) {
        //_isLoading = false;
      }
    }
    _isLoading = false;
    notifyListeners(); //scatena un cambio di route verso '/' che poi checks on isBackendVerified
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await retrieveBackendUser();
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
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
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
      await retrieveBackendUser();
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
  }

  // Method to perform backend verification
  Future<void> retrieveBackendUser() async {
    try {
      final idToken = await _user?.getIdToken();
      if (idToken != null) {
        await UserService().retrieveUser(); //sets user and profiles if successful
        _isBackendVerified = true;
      } else {
        throw "It was not possible to login";
      }
    } catch (e) {
      throw e.toString();
    }

    notifyListeners(); //successful, move to HomePage
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
