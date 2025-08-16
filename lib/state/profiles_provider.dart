import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';

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
      _profiles[profile.hash] = profile;
    }
    notifyListeners();
  }

}
