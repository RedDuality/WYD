import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wyd_front/service/user/user_service.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class AuthenticationProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = true;
  bool _firstTimeLogging = false;

  static final AuthenticationProvider _instance = AuthenticationProvider._internal();
  factory AuthenticationProvider() => _instance;

  User? get user => _auth.currentUser;
  bool get isLoading => _isLoading;
  bool get isFirstTimeLogging => _firstTimeLogging;

  AuthenticationProvider._internal() {
    _assureUserIsLoaded();

    _auth.authStateChanges().listen((User? user) => _onUserChange(user));
  }

  Future<void> _assureUserIsLoaded() async {
    if (await isLoggedIn()) {
      if (kIsWeb) {
        await UserService.retrieveUser();
      } else {
        await UserCache().initialize();
      }
    }
    _isLoading = false;
    notifyListeners(); //triggers a redirect that checks over UserService.isLoggedIn (see main)
  }

  void _onUserChange(User? user) {
    // be careful of token refresh after registration(userId added to the token)

    // if, for any reason(e.g. logout), the user is no more, it returns to the login page
    if (user == null) {
      _firstTimeLogging = false;
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    final idToken = await user?.getIdToken();
    return idToken != null;
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
      await UserService.createBackendUser();
      await _auth.currentUser?.getIdToken(true); // refresh token, as now it should contains the userId
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
    _firstTimeLogging = true;
    notifyListeners(); // now UserService.isLoggedIn should be true
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
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
    try {
      await UserService.retrieveUser();
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
    _firstTimeLogging = true;
    notifyListeners(); // now UserService.isLoggedIn should be true
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
