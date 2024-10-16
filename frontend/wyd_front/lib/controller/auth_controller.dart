import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/login_dto.dart';
import 'package:wyd_front/service/auth_service.dart';

class AuthController {

  Future<bool> register(mail, String password) async {
    bool res = false;
    return res;
  }


  Future<bool> login(mail, String password) async {
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
