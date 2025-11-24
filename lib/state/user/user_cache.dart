import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/state/user/user_storage.dart';

class UserCache extends ChangeNotifier {
  late User _user;

  final UserStorage _storage = UserStorage();

  StreamSubscription<User>? _userUpdateSubscription;

  UserCache() {
    _initialize();

    _userUpdateSubscription = _storage.userUpdatesChannel.listen((user) {
      _updateUser(user);
    });
  }

  void _initialize() async {
    final user = await UserStorage.getUser();
    if (user != null) _user = user;
  }

  User get user => _user;

  String getCurrentProfileId() {
    return _user.currentProfileHash;
  }

  Set<String> getProfileIds() {
    return Set<String>.from(_user.profileIds);
  }

  Set<String> getSecondaryProfilesHashes() {
    var profiles = getProfileIds();
    profiles.remove(getCurrentProfileId());
    return profiles;
  }

  void _updateUser(User user) {
    _user = user;
    // notifyListeners();
  }

  void setCurrentProfile(String profileHash) {
    _user.currentProfileHash = profileHash;
    notifyListeners();
  }

  @override
  void dispose() {
    _userUpdateSubscription?.cancel();
    super.dispose();
  }
}
