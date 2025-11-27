import 'dart:async';
import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/model/profiles/profile.dart';
import 'package:wyd_front/service/profile/profile_retrieve_service.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';

class ProfileStorageService {
  static Future<Profile?> retrieve(String profileId) async {
    var profile = await ProfileStorage().getProfileById(profileId);

    final aDayAgo = DateTime.now().subtract(Duration(days: 1));
    if (profile == null || profile.lastFetched.isBefore(aDayAgo)) {
      unawaited(ProfileRetrieveService().retrieve(profileId));
    }
    return profile;
  }

  static Future<void> addProfiles(List<RetrieveProfileResponseDto> dtos) async {
    for (var dto in dtos) {
      await addProfile(dto);
    }
  }

  static Future<void> addProfile(RetrieveProfileResponseDto dto) async {
    var profile = Profile.fromDto(dto);
    await ProfileStorage().saveProfile(profile);
  }
}
