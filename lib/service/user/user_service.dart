import 'dart:async';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
import 'package:wyd_front/model/user_claim.dart';
import 'package:wyd_front/model/view_settings.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/service/profile/detailed_profile_storage_service.dart';
import 'package:wyd_front/service/util/real_time_updates_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/profile/detailed_profile_storage.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/user/user_claims_storage.dart';
import 'package:wyd_front/state/user/user_provider.dart';
import 'package:wyd_front/state/user/view_settings_storage.dart';
import 'package:wyd_front/state/util/event_intervals_cache_manager.dart';

class UserService {
  Future<void> createUser() async {
    RetrieveUserResponseDto userDto = await UserAPI().register();
    _updateUser(userDto);
  }

  Future<void> retrieveUser() async {
    RetrieveUserResponseDto userDto = await UserAPI().login();
    _updateUser(userDto);
  }

  Future<void> _updateUser(RetrieveUserResponseDto userDto) async {
    await UserProvider().updateUser(User.fromDto(userDto));

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

  Future<void> logOut() async {
    await RealTimeUpdateService().deleteTokenOnLogout();

    EventStorage().clearAllEvents();
    EventIntervalsCacheManager().clearAllIntervals();
    
    ProfileStorage().clearAllProfiles();
    DetailedProfileStorage().clearAll();
    ViewSettingsStorage().clearAll();
    UserClaimStorage().clearAll();

    AuthenticationProvider().signOut();
  }
}
