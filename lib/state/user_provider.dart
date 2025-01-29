import 'package:flutter/material.dart';
import 'package:wyd_front/model/user.dart';

class UserProvider extends ChangeNotifier {

  static final UserProvider _instance = UserProvider._internal();

  factory UserProvider() {
    return _instance;
  }

  UserProvider._internal();

  User? _user;

  User? get user => _user;

  String getCurrentProfileHash() {
    return _user!.currentProfileHash;
  }

  Set<String> getSecondaryProfilesHashes(){
    var profiles = getProfileHashes();
    profiles.remove(getCurrentProfileHash());
    return profiles;
  }

  Set<String> getProfileHashes() {
    return _user!.profileHashes;
  }

  Future<void> updateUser(User user) async {
    _user == null
        ? setUser(user)
        : //
        checkUserUpdate(user);

    notifyListeners();
  }

  checkUserUpdate(user) {
    if (_user!.hash == user.hash) {
    } else {
      setUser(user);
    }
  }

  void setUser(User user) {
    _user = user;
  }

  void setCurrentProfile(String profileHash) {
    _user!.currentProfileHash = profileHash;
    notifyListeners();
  }
}
