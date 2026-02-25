import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';

class GoogleSignInService with ChangeNotifier {
  static bool _isGoogleSignInInitialized = false;
  static bool get isGoogleSignInInitialized => _isGoogleSignInInitialized;

  static GoogleSignInAccount? _currentUser;
  static GoogleSignInAccount? get currentUser => _currentUser;

  Future<void> initialize() async {
    try {
      await GoogleSignIn.instance.initialize(
        clientId: ConfigService().googleClientId,
        serverClientId: kIsWeb ? null : ConfigService().googleClientId,
      );

      if (kIsWeb) {
        // Listen to sign-in events. This is triggered by the 'renderButton' in the UI.
        GoogleSignIn.instance.authenticationEvents.listen(
          (event) async {
            switch (event) {
              case GoogleSignInAuthenticationEventSignIn():
                await _handleGoogleSignIn(event.user);
                _currentUser = event.user;
              case GoogleSignInAuthenticationEventSignOut():
                await AuthenticationProvider().signOut();
            }
          },
        ).onError((error) {
          debugPrint("Google Sign-In stream error: $error");
        });
      }
      _isGoogleSignInInitialized = true;
      debugPrint("Google Sign-In initialized and listening for events");
    } catch (e) {
      debugPrint("Error initializing Google Sign-In: $e");
      _isGoogleSignInInitialized = false;
    }
  }

  // for web — called by the auth event stream
  Future<void> _handleGoogleSignIn(GoogleSignInAccount googleUser) async {
    try {
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      AuthenticationProvider().signInWithCredential(credential);
    } catch (e) {
      debugPrint("Unexpected error during Google Sign-In: $e");
      rethrow;
    }
  }

  // for Android/ios
  static Future<void> signInWithGoogle() async {
    if (!_isGoogleSignInInitialized) {
      throw "Google Sign-In is not initialized. Please try again.";
    }

    try {
      try {
        _currentUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          debugPrint("User canceled Google Sign-In");
          return;
        }
        rethrow;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: _currentUser!.authentication.idToken,
      );

      AuthenticationProvider().signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      throw "Google Sign-In failed, please try again.";
    }
  }

  /// Signs in to Google, targeting a specific account by [email].
  ///
  /// - If the current user already matches [email], returns immediately.
  /// - If a different user is signed in, signs out first so the account picker
  ///   won't silently reuse the wrong account.
  /// - After authentication, verifies the selected account matches [email].
  ///   Throws if the user picked a different one.
  ///
  /// Returns the authenticated [GoogleSignInAccount] for the requested email.

  static Future<GoogleSignInAccount> signInForAccount(String email) async {
    if (!_isGoogleSignInInitialized) {
      throw "Google Sign-In is not initialized. Please try again.";
    }

    // Fast path: already signed in with the right account.
    if (_currentUser != null && _currentUser!.email == email) {
      return _currentUser!;
    }

    // If a different account is active, sign out
    if (_currentUser != null && _currentUser!.email != email) {
      await signOut();
    }

    // Attempt a lightweight (silent) re-authentication first — this succeeds
    // when the device/OS still has a valid session for that account
    try {
      final lightweight = await GoogleSignIn.instance.attemptLightweightAuthentication();
      if (lightweight != null) {
        if (lightweight.email == email) {
          _currentUser = lightweight;
          return _currentUser!;
        }
        await signOut();
      }
    } catch (_) {
    }

    // Interactive sign-in. Passing the target email as scopeHint is not
    // supported by the v7 API
    try {
      _currentUser = await GoogleSignIn.instance.authenticate(
        scopeHint: ['email'],
      );
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw "Sign-in canceled. Please try again and select $email.";
      }
      rethrow;
    }

    // Guard: reject if the user picked a different account than expected.
    if (_currentUser!.email != email) {
      final selected = _currentUser!.email;
      await signOut();
      throw "Wrong account selected. Expected $email but got $selected. "
          "Please try again and select the correct account.";
    }

    return _currentUser!;
  }

  static Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    _currentUser = null;
  }
}
