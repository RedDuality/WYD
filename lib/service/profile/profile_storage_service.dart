import 'dart:async';

import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/profile/profile_retrieve_service.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfileStorageService {
  static Future<void> addProfile(RetrieveProfileResponseDto dto) async {
    var profile = Profile.fromDto(dto);
    if (profile.color != null) {
      await _checkColorChanged(profile);
    }
    ProfileStorage().saveProfile(profile);
  }

  static Future<void> _checkColorChanged(Profile profile) async {
    
    var myProfiles = UserProvider().getProfileHashes();
    if (myProfiles.contains(profile.id)) {
      var oldProfile = await ProfileStorage().getProfileById(profile.id);
      if(oldProfile!.color != profile.color){
        // TODO unawaited(eventProvider.refresh());
      }
    }
  }

  static void addProfiles(List<RetrieveProfileResponseDto> dtos) {
    var profiles = dtos.map((dto) => Profile.fromDto(dto)).toList();
    ProfileStorage().saveMultiple(profiles);
  }

  static Future<Profile?> retrieve(String profileId) async {
    var profile = await ProfileStorage().getProfileById(profileId);

    final aDayAgo = DateTime.now().subtract(Duration(days: 1));
    if (profile == null || profile.lastFetched.isBefore(aDayAgo)) {
      unawaited(ProfileRetrieveService().retrieve(profileId));
    }
    return profile;
  }
}
