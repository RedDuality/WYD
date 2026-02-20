import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';

class GoogleSignInService with ChangeNotifier {
  static bool _isGoogleSignInInitialized = false;
  static bool get isGoogleSignInInitialized => _isGoogleSignInInitialized;

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

  // for web
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
  Future<void> signInWithGoogle() async {
    if (!_isGoogleSignInInitialized) {
      throw "Google Sign-In is not initialized. Please try again.";
    }

    try {
      GoogleSignInAccount googleUser;

      try {
        googleUser = await GoogleSignIn.instance.authenticate(scopeHint: ['email']);
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          debugPrint("User canceled Google Sign-In");
          return;
        }
        rethrow;
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleUser.authentication.idToken,
      );

      AuthenticationProvider().signInWithCredential(credential);
    } catch (e) {
      debugPrint("Google Sign-In Error: $e");
      throw "Google Sign-In failed, please try again.";
    }
  }
}
