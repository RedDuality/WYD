import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';


class ProfilesProvider extends ChangeNotifier {
  // Private static instance
  static final ProfilesProvider _instance = ProfilesProvider._internal();

  // Factory constructor returns the singleton instance
  factory ProfilesProvider() {
    return _instance;
  }

  // Private named constructor
  ProfilesProvider._internal();

  final List<Profile> _profiles = [];

  Profile? get(String hash){
    return _profiles.where((p)=> p.hash == hash).firstOrNull; 
  }

  void addAll(List<Profile> profiles){
    _profiles.addAll(profiles);
  }
}
