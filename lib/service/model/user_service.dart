import 'dart:async';
import 'package:wyd_front/API/auth_api.dart';
import 'package:wyd_front/model/DTO/retrieve_user_dto.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/state/profiles_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class UserService {
  Future<void> verifyToken(String token) async {
    RetrieveUserDto userDto = await AuthAPI().verifyToken(token);
    User user = User.fromDto(userDto);

    await UserProvider().updateUser(user);
    ProfilesProvider().addAll(userDto.profiles);
  }
}
