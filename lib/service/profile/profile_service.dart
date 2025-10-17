import 'dart:async';
import 'dart:ui';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';

class ProfileService {
  static Future<void> updateProfile(UpdateProfileRequestDto updateDto, Profile profile) async {
    await ProfileAPI().updateProfile(updateDto);

    if (updateDto.color != null) profile.color = Color(updateDto.color!);
    if (updateDto.name != null) profile.name = updateDto.name!;
    if (updateDto.tag != null) profile.tag = updateDto.tag!;
    
    ProfileStorage().saveProfile(profile);
  }

  static Future<List<Profile>> searchByTag(String searchTag) async {
    final dtos = await ProfileAPI().searchByTag(searchTag);
    return dtos.map((d) => Profile.fromDto(d)).toList();
  }
}
