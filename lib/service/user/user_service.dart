import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
import 'package:wyd_front/model/users/user_claim.dart';
import 'package:wyd_front/model/users/view_settings.dart';
import 'package:wyd_front/model/users/user.dart';
import 'package:wyd_front/service/profile/detailed_profile_storage_service.dart';
import 'package:wyd_front/service/util/real_time/real_time_update_service.dart';
import 'package:wyd_front/state/event/event_intervals_manager.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';
import 'package:wyd_front/state/media/media_flag_storage.dart';
import 'package:wyd_front/state/media/media_storage.dart';
import 'package:wyd_front/state/profile/detailed_profile_storage.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';
import 'package:wyd_front/state/profileEvent/detailed_profile_events_storage.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/user/user_claims_storage.dart';
import 'package:wyd_front/state/user/user_storage.dart';
import 'package:wyd_front/state/user/view_settings_storage.dart';

class UserService {
  static Future<void> retrieveUser() async {
    try {
      final userDto = await UserAPI().login();
      await _updateUser(userDto);
    } catch (e) {
      logOut();
      throw e.toString();
    }
  }

  static Future<void> createBackendUser() async {
    try {
      final userDto = await UserAPI().register();
      await _updateUser(userDto);
    } catch (e) {
      logOut();
      throw e.toString();
    }
  }

  static Future<void> _updateUser(RetrieveUserResponseDto userDto) async {
    final user = User.fromDto(userDto);
    await UserStorage().saveUser(user);

    DetailedProfileStorageService.addMultiple(userDto.profiles);

    var settingsList = userDto.profiles
        .expand((profile) {
          return profile.viewSettings ?? [];
        })
        .cast<ViewSettings>()
        .toList();

    var userClaims = userDto.profiles
        .expand((profile) {
          return profile.userClaims ?? [];
        })
        .cast<UserClaim>()
        .toList();

    ViewSettingsStorage().saveMultiple(settingsList);
    UserClaimStorage().saveMultiple(userClaims);
  }

  static Future<void> logOut() async {
    debugPrint("logout");
    RealTimeUpdateService().dispose();

    // storages
    EventStorage().clearAll();
    EventIntervalsManager().clearAll();

    MaskStorage().clearAll();
    
    DetailedProfileEventsStorage().clearAll();

    MediaFlagStorage().clearAll();
    MediaStorage().clearAll();

    ProfileStorage().clearAll();
    DetailedProfileStorage().clearAll();
    ViewSettingsStorage().clearAll();
    UserClaimStorage().clearAll();

    UserStorage().clearAll();
    
    AuthenticationProvider().signOut();
  }
}
