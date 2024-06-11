import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/login_dto.dart';
import 'package:wyd_front/service/auth_service.dart';
import 'package:wyd_front/view/home_page.dart';

class AuthController {
  Future<bool> login(BuildContext context, mail, String password) async {
    bool res = true;
    LoginDto loginDto = LoginDto(mail, password);

    AuthService().login(loginDto).then((response) async {
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('token', response.body);

        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              ModalRoute.withName('/'));
        }
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
