import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/login_dto.dart';
import 'package:wyd_front/service/auth_service.dart';
import 'package:wyd_front/view/home_page.dart';

class AuthController {
  Future<void> login(BuildContext context, mail, String password) async {

    LoginDto loginDto = LoginDto(mail, password);

    AuthService().login(loginDto).then((response) async {
      if (response.statusCode == 200) {

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.body);

        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HomePage()));
      }
    }).catchError((error) {
      print("error$error");
    });
  }

  Future<bool> testToken() async {
    bool res = false;

    await AuthService().testToken().then((response) {
      if (response.statusCode == 200) {
        res = true;
      }
    }).catchError((error) {
      print("error$error");
    });

    return res;
  }
}
