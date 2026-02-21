import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wyd_front/service/user/user_service.dart';
import 'package:wyd_front/service/util/authentication/google_sing_in_service.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class AuthenticationProvider with ChangeNotifier {
  static final AuthenticationProvider _instance = AuthenticationProvider._internal();
  factory AuthenticationProvider() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get user => _auth.currentUser;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthenticationProvider._internal() {
    _initializeExternalServices().then((_) {
      _auth.authStateChanges().listen((User? user) => _onUserChange(user));
      _assureUserIsLoaded();
    });
  }

  Future<void> _initializeExternalServices() async {
    for (final platform in ConfigService().supportedAuthPlatforms) {
      switch (platform) {
        case SignInPlatform.google:
          await GoogleSignInService().initialize();
      }
    }
  }

  void _onUserChange(User? user) {
    // be careful of token refresh after registration(userId added to the token)

    // if, for any reason(e.g. logout), the user is no more, it returns to the login page
    if (user == null) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isLoggedIn() async {
    final idToken = await user?.getIdToken();
    return idToken != null;
  }

  Future<void> _assureUserIsLoaded() async {
    if (await isLoggedIn()) {
      await UserCache().initialize();
    }
    _isLoading = false;
    notifyListeners(); // triggers a redirect that checks over isLoggedIn (see main -> router)
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> _register() async {
    try {
      await UserService.createBackendUser();
      await _auth.currentUser?.getIdToken(true); // refresh token, as it should now contains the userId
    } on Exception catch (e) {
      debugPrint("Error registering: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
    notifyListeners(); // now UserService.isLoggedIn should be true
  }

  Future<void> _signIn() async {
    try {
      await UserService.retrieveUser();
    } on Exception catch (e) {
      debugPrint("Error loggin: $e");
      await _auth.currentUser?.delete();
      throw "Unexpected error, please try later";
    }
    notifyListeners(); // now UserService.isLoggedIn should be true
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
    await _register();
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
    await _signIn();
  }

  Future<void> signInWithCredential(AuthCredential credential) async {
    final UserCredential userCredential;

    try {
      userCredential = await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Error: $e");
      throw "Unexpected error, please try later";
    } catch (e) {
      debugPrint("Sign In Error: $e");
      throw "An unexpected error occurred.";
    }

    final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

    if (isNewUser) {
      await _register();
    } else {
      await _signIn();
    }
  }
}
