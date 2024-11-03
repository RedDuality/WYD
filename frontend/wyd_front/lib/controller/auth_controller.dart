import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/service/auth_service.dart';
import 'package:wyd_front/state/authentication_provider.dart';

class AuthController {
  Future register(BuildContext context, String mail, String password) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    try {
      await authProvider.register(mail, password);

      final idToken = await authProvider.user?.getIdToken();

      if (idToken != null && context.mounted) {
        final response = await AuthService(context).verifyTokenAndCreate(idToken);

        if (response.statusCode != 200) {
          throw Exception("Failed to verify registration on the backend");
        }
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw e.message.toString();
      } else if (e.code == 'email-already-in-use') {
        throw e.message.toString();
      } else {
        throw "Unexpected error, please try later";
      }
    }
  }

  Future login(BuildContext context, String mail, String password) async {
    final authProvider =
        Provider.of<AuthenticationProvider>(context, listen: false);
    try {
      await authProvider.signIn(mail, password);

      final idToken = await authProvider.user?.getIdToken();

      if (idToken != null && context.mounted) {
        final response = await AuthService(context).verifyToken(idToken);
        if (response.statusCode != 200) {
          throw Exception("Failed to verify login on the backend");
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception("Please insert a valid email");
      }
      if (e.code == 'invalid-credential') {
        throw Exception("The mail or the password provided are wrong");
      } else {
        throw "Unexpected error, please try later";
      }
    }
  }
}
