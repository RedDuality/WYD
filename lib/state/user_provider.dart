import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/model/user.dart';

class UserProvider extends ChangeNotifier {
  // Private static instance
  static final UserProvider _instance = UserProvider._internal();

  // Factory constructor returns the singleton instance
  factory UserProvider() {
    return _instance;
  }

  // Private named constructor
  UserProvider._internal();

  User? _user;
  Profile? _currentProfile;

  User? get user => _user;

  String getCurrentProfileHash() {
    return _currentProfile!.hash;
  }

  void updateUser(User user) {
    _user == null
        ? setUser(user)
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
    _currentProfile =
        user.profiles.firstWhere((p) => p.hash == user.mainProfileHash);
  }

  void setCurrentProfile(Profile profile){
    _currentProfile = profile;
    notifyListeners();
  }
}
