import 'package:flutter/material.dart';
import 'package:wyd_front/controller/my_event_controller.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';
import 'package:wyd_front/model/user.dart';

class UserProvider extends ChangeNotifier {
  BuildContext context;

  User? _user;

  UserProvider({required this.context});

  User? get user => _user;

  int getMainProfileId() {
    return user!.profiles
        .firstWhere(
            (p) => p.type == ProfileType.personal && p.role == Role.owner)
        .id;
  }

  void updateUser(User? user) {
    _user == null
        ? setUser(user!)
        : //
        checkUserUpdate(user);

    notifyListeners();
  }

  checkUserUpdate(user) {
    if (_user!.id == user.id) {
      //TODO check user updates on profiles
    } else {
      setUser(user);
    }
  }

  void setUser(User user) {
    _user = user;
    MyEventController().retrieveEvents(context);
    notifyListeners();
  }
}
