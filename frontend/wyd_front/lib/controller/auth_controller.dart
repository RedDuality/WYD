import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/login_dto.dart';
import 'package:wyd_front/service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  Future<bool> register(String mail, String password) async {
    bool res = false;
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: mail, password: password);
      debugPrint(userCredential.toString());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw e.message.toString();
      } else if (e.code == 'email-already-in-use') {
        throw e.message.toString();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return res;
  }

  Future<bool> fireLogin(String mail, String password) async {
    bool res = false;

    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: mail, password: password);
      debugPrint(credential.toString());
      // Get the ID Token from the Firebase user
      final idToken = await credential.user?.getIdToken();

      // Send the ID Token to the backend for verification
      if (idToken != null) {
        final response = await AuthService().verifyLoginToken(idToken);

        // Handle the response (e.g., if the backend returns user data or tokens)
        if (response.statusCode == 200) {
          debugPrint(response.body);
          res = true;
        } else {
          throw Exception("Failed to verify login on the backend");
        }
      }

    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-email') {
        throw Exception("Please insert a valid email");
      } if (e.code == 'invalid-credential') {
        throw Exception("The mail or the password provided are wrong");
      } else {
        debugPrint(e.code);
        throw "Unexpected error, please try later";
      }
    } on Error catch (error) {
      debugPrint("error $error");
    }
    return res;
  }

  Future<bool> login(String mail, String password) async {
    bool res = false;
    LoginDto loginDto = LoginDto(mail, password);

    await AuthService().login(loginDto).then((response) async {
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.body);
        res = true;
      }
    }).catchError((error) {
      debugPrint("error$error");
    });

    return res;
  }

  Future<bool> testToken() async {
    bool res = false;

    await AuthService().testToken().then((response) {
      if (response.statusCode == 200) {
        res = true;
      }
    }).catchError((error) {
      debugPrint("error$error");
    });

    return res;
  }
}
