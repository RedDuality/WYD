import 'dart:async';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/API/Profile/retrieve_detailed_profile_response_dto.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/model/detailed_profile.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/state/profile/detailed_profile_storage.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';

class DetailedProfileStorageService {
  static Future<DetailedProfile?> retrieve(String profileId) async {
    var profile = await DetailedProfileStorage().getById(profileId);

    final aDayAgo = DateTime.now().subtract(Duration(days: 1));
    if (profile == null || profile.lastFetched.isBefore(aDayAgo)) {
      unawaited(retrieveFromServer(profileId));
    }
    return profile;
  }

  static Future<void> retrieveFromServer(String profileId) async {
    var dto = await ProfileAPI().retrieveDetailed(profileId);
    localUpdate(dto);
  }

  static Future<void> updateProfile(UpdateProfileRequestDto updateDto) async {
    var responseDto = await ProfileAPI().updateProfile(updateDto);
    localUpdate(responseDto);
  }

  static Future<void> localUpdate(RetrieveDetailedProfileResponseDto dto) async {
    _checkColorChanged(dto);
    await _addSingle(dto);
  }

  static Future<void> _checkColorChanged(RetrieveDetailedProfileResponseDto dto) async {
    var oldProfile = await DetailedProfileStorage().getById(dto.id);
    if (oldProfile!.color != dto.color) {
      EventViewService.notifyProfileColorChanged();
    }
  }

  static Future<void> _addSingle(RetrieveDetailedProfileResponseDto dto) async {
    final updatedProfile = DetailedProfile.fromDto(dto);
    final profile = Profile.fromDetailed(updatedProfile);

    DetailedProfileStorage().saveProfile(updatedProfile);
    ProfileStorage().saveProfile(profile);
  }

  static Future addMultiple(List<RetrieveDetailedProfileResponseDto> profileDtos) async {
    var detailedProfiles = profileDtos.map(DetailedProfile.fromDto).toList();
    var profiles = detailedProfiles.map(Profile.fromDetailed).toList();

    DetailedProfileStorage().saveMultiple(detailedProfiles);
    ProfileStorage().saveMultiple(profiles);
  }
}
