import 'package:flutter/material.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/model/user.dart';

class UserProvider extends ChangeNotifier {

  User? _user;

  User? get user => _user;

  int getMainProfileId() {
    return user!.mainProfileId;
  }

  void updateUser(BuildContext context, User user) {
    _user == null
        ? setUser(context, user)
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
    EventService(context:context).retrieveEvents();
    notifyListeners();
  }
}
