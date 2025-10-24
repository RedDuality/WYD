import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wyd_front/API/Profile/retrieve_profile_response_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/profile/profile_retrieve_service.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class ProfileStorageService {
  static void addProfiles(List<RetrieveProfileResponseDto> dtos) {
    dtos.map((dto) => addProfile(dto));
  }

  static Future<void> addProfile(RetrieveProfileResponseDto dto) async {
    var profile = Profile.fromDto(dto);
    ProfileStorage().saveProfile(profile);
  }

  static Future<void> update(RetrieveProfileResponseDto dto) async {
    var oldProfile = await ProfileStorage().getProfileById(dto.id);
    if (dto.color != null) {
      _checkColorChanged(dto.color!, oldProfile!);
    }

    final updatedProfile = Profile(
      id: oldProfile!.id,
      tag: dto.tag ?? oldProfile.tag,
      name: dto.name ?? oldProfile.name,
      lastFetched: oldProfile.lastFetched,
      updatedAt: dto.updatedAt ?? oldProfile.updatedAt,
      blobHash: dto.blobHash ?? oldProfile.blobHash,
      color: dto.color ?? oldProfile.color,
      role: dto.role ?? oldProfile.role,
      mainProfile: dto.mainProfile ?? oldProfile.mainProfile,
    );

    ProfileStorage().saveProfile(updatedProfile);
  }

  static Future<void> _checkColorChanged(Color newColor, Profile original) async {
    if (original.color != newColor) {
      var myProfiles = UserProvider().getProfileHashes();
      if (myProfiles.contains(original.id)) {
        EventViewService.notifyProfileColorChanged();
      }
    }
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
