import 'dart:async';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/profile/profile_storage_service.dart';

class ProfileService {
  static Future<void> updateProfile(UpdateProfileRequestDto updateDto, Profile profile) async {
    var responseDto = await ProfileAPI().updateProfile(updateDto);
    
    ProfileStorageService.update(responseDto);
  }

  static Future<List<Profile>> searchByTag(String searchTag) async {
    final dtos = await ProfileAPI().searchByTag(searchTag);
    return dtos.map((d) => Profile.fromDto(d)).toList();
  }
}
