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

  String getCurrentProfileId() {
    return _user!.currentProfileHash;
  }

  Set<String> getProfileIds() {
    return Set<String>.from(_user!.profileIds);
  }

  Set<String> getSecondaryProfilesHashes() {
    var profiles = getProfileIds();
    profiles.remove(getCurrentProfileId());
    return profiles;
  }

  Future<void> updateUser(User user) async {
    if (_user == null || _user!.id != user.id) {
      _user = user;
      notifyListeners();
    }
  }

  void setCurrentProfile(String profileHash) {
    _user!.currentProfileHash = profileHash;
    notifyListeners();
  }
}
