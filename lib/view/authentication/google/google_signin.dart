import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wyd_front/service/util/authentication/google_sing_in_service.dart';
import 'package:wyd_front/service/util/information_service.dart';

import 'google_signin_web_stub.dart' if (dart.library.js_util) 'google_signin_web_imp.dart';

class GoogleSignin extends StatelessWidget {
  const GoogleSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Google Sign-In button - only show if initialized and supported
        if (GoogleSignIn.instance.supportsAuthenticate())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 450),
                child: ElevatedButton.icon(
                  icon: Image.asset('assets/images/google_logo.png', height: 24),
                  label: const Text('Sign in with Google'),
                  onPressed: () {
                    GoogleSignInService().signInWithGoogle().catchError((error) {
                      if (context.mounted) {
                        InformationService().showErrorSnackBar(context, error.toString());
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

        if (kIsWeb)
          Container(
            constraints: const BoxConstraints(maxWidth: 435),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            alignment: Alignment.center,
            child: getWebGoogleButton(),
          ),
      ],
    );
  }
}
