import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/controller/my_event_controller.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/model/user_dto.dart';

import 'package:wyd_front/service/user_service.dart';
import 'package:wyd_front/state/my_app_state.dart';

class UserController {
  Future<void> initUser(BuildContext context) async {

    UserService(context).retrieve().then((response) {
      if (response.statusCode == 200 && context.mounted) {
        UserDto userDto = UserDto.fromJson(jsonDecode(response.body));
        context.read<MyAppState>().setUser(User.fromDto(userDto));

        MyEventController().setEvents(context, userDto.events);
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });
  }

}
