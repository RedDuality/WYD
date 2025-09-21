import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfilesProvider extends ChangeNotifier {

  static final ProfilesProvider _instance = ProfilesProvider._internal();

  factory ProfilesProvider() {
    return _instance;
  }

  ProfilesProvider._internal();


  final Map<String, Profile> _profiles = {};



  Profile? get(String hash) => _profiles[hash];

  void addAll(List<Profile> profiles) {
    for (final profile in profiles) {
      _profiles[profile.eventHash] = profile;
    }
    notifyListeners();
  }

  List<Profile> getMyProfiles() {
    var profileHashes = UserProvider().getProfileHashes();
    return _profiles.values.where((element) => profileHashes.contains(element.eventHash)).toList();
  }
  
}
