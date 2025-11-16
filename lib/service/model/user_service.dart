import 'dart:async';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/service/util/real_time_updates_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';
import 'package:wyd_front/state/user/authentication_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';
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
    User user = User.fromDto(userDto);

    await UserProvider().updateUser(user);

    ProfileStorage().saveMultiple(userDto.profiles);
  }

  Future<void> logOut() async {
    await RealTimeUpdateService().deleteTokenOnLogout();

    EventStorage().clearAllEvents();
    EventIntervalsCacheManager().clearAllIntervals();
    ProfileStorage().clearAllProfiles();

    AuthenticationProvider().signOut();
  }
}
