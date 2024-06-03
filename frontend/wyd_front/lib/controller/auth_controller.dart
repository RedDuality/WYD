

import 'package:flutter/material.dart';
import 'package:wyd_front/model/loginDto.dart';
import 'package:wyd_front/service/auth_service.dart';

class AuthController{
  BuildContext? context;

  AuthController(BuildContext context){
    context = context;
  }


  Future<void> login(String mail, String password) async {

    
    LoginDto loginDto = LoginDto(mail, password);

    final response = await AuthService().login(loginDto);



    //TODO aggiornare stato: aggiungere private a privateEvents e public a publicevents(da creare)
    
    //debugPrint('$eventi');
  }
}