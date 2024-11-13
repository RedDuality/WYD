import 'package:flutter/material.dart';
import 'package:wyd_front/controller/my_event_controller.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';
import 'package:wyd_front/model/user.dart';

class UserProvider extends ChangeNotifier {

  User? _user;

  User? get user => _user;

  int getMainProfileId() {
    return user!.profiles
        .firstWhere(
            (p) => p.type == ProfileType.personal && p.role == Role.owner)
        .id;
  }

  void updateUser(BuildContext context, User? user) {
    _user == null
        ? setUser(context, user!)
        : //
        checkUserUpdate(context, user);

    notifyListeners();
  }

  checkUserUpdate(context, user) {
    if (_user!.id == user.id) {
      //TODO check user updates on profiles
    } else {
      setUser(context, user);
    }
  }

  void setUser(BuildContext context, User user) {
    _user = user;
    MyEventController(context:context).retrieveEvents();
    notifyListeners();
  }
}
