

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/login_dto.dart';
import 'package:wyd_front/service/auth_service.dart';
import 'package:wyd_front/state/login_state.dart';
import 'package:wyd_front/view/home_page.dart';

class AuthController{

  Future<void> login(BuildContext context,  mail, String password) async {

    var loginState = context.read<LoginState>();
    LoginDto loginDto = LoginDto(mail, password);

    AuthService().login(loginDto)
    .then((response){
      if(response.statusCode == 200){
        loginState.loginSuccessful();
        print("token: ${response.body}");
        //TODO salvare token in memoria
        Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HomePage()));
      }
    }).catchError((error){
      print("error$error");
      });

  }
}