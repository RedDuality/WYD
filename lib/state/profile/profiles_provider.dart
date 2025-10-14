import 'package:flutter/material.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfilesProvider extends ChangeNotifier {

  static final ProfilesProvider _instance = ProfilesProvider._internal();

  factory ProfilesProvider() {
    return _instance;
  }

  ProfilesProvider._internal();


  final Map<String, Profile> _profiles = {};



  Profile? get(String id) => _profiles[id];

  void set(String id, Profile profile){
    _profiles[id] = profile;
    notifyListeners();
  }

  void update(UpdateProfileRequestDto updateDto){
    var profile = _profiles[updateDto.profileHash]!;
    if(updateDto.color != null) profile.color = Color(updateDto.color!);
    if(updateDto.name != null) profile.name = updateDto.name!;
    if(updateDto.tag!=null) profile.tag = updateDto.tag!;
    set(profile.id, profile);
  }

  void addAll(List<Profile> profiles) {
    for (final profile in profiles) {
      _profiles[profile.id] = profile;
    }
    notifyListeners();
  }

  List<Profile> getMyProfiles() {
    var profileHashes = UserProvider().getProfileHashes();
    return _profiles.values.where((element) => profileHashes.contains(element.id)).toList();
  }

  
}
