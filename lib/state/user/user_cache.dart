import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/user.dart';
import 'package:wyd_front/state/user/user_storage.dart';

class UserCache extends ChangeNotifier {
  late User? _user;

  StreamSubscription<User>? _userUpdateSubscription;

  static final UserCache _instance = UserCache._internal();
  factory UserCache() => _instance;
  UserCache._internal();

  Future<void> initialize() async {
    _user = (await UserStorage.getUser())!;
  }

  User? get user => _user;

  String getUserId() => _user!.id;

  String getCurrentProfileId() => _user!.currentProfileId;

  Set<String> getProfileIds() => _user!.profileIds;

  Set<String> getSecondaryProfilesHashes() {
    var profiles = getProfileIds();
    profiles.remove(getCurrentProfileId());
    return profiles;
  }

  void updateUser(User user) {
    _user = user;
    // notifyListeners();
  }

  void setCurrentProfile(String profileHash) {
    _user!.currentProfileId = profileHash;
    notifyListeners();
  }

  @override
  void dispose() {
    _userUpdateSubscription?.cancel();
    super.dispose();
  }
}
