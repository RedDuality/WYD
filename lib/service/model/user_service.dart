import 'dart:async';
import 'package:wyd_front/API/User/user_api.dart';
import 'package:wyd_front/API/User/retrieve_user_response_dto.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class UserService {
  Future<void> retrieveUser() async {
    RetrieveUserResponseDto userDto = await UserAPI().retrieve();
    User user = User.fromDto(userDto);

    await UserProvider().updateUser(user);
    ProfilesProvider().addAll(userDto.profiles);
  }
}
