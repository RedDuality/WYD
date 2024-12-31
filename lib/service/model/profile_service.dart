import 'package:wyd_front/API/profile_api.dart';
import 'package:wyd_front/model/profile.dart';

class ProfileService {
  Future<List<Profile>?> searchByTag(String searchTag) async {
    return ProfileAPI().searchByTag(searchTag);
  }
}
