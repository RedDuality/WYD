import 'dart:async';
import 'package:wyd_front/API/profile_api.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profiles_provider.dart';

class ProfileService {

  Future<List<Profile>?> searchByTag(String searchTag) async {
    return ProfileAPI().searchByTag(searchTag);
  }

  Future<List<Profile>> retrieveProfiles(List<String> hashes) async {
    final profiles = await ProfileAPI().retrieveFromHashes(hashes);
    ProfilesProvider().addAll(profiles);
    return profiles;
  }


}
