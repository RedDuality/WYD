import 'dart:convert';

import 'package:wyd_front/API/community_api.dart';
import 'package:wyd_front/model/DTO/create_community_dto.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/community_provider.dart';

class CommunityService {
  Future<void> retrieveCommunities(Profile profile) async {
    var response = await CommunityAPI().retrieveCommunities(profile);

    if (response.statusCode == 200) {

      List<dynamic> parsedJson = json.decode(response.body);
      List<Community> myCommunities = parsedJson
          .map((community) =>
              Community.fromJson(community as Map<String, dynamic>))
          .toList();

      CommunityProvider().addRange(myCommunities);
    } else {
      throw "Error while creating the community, please retry later";
    }
  }

  Future<void> create(CreateCommunityDto community) async {
    var response = await CommunityAPI().create(community);

    if (response.statusCode == 200) {
      Community newCommunity = Community.fromJson(jsonDecode(response.body));

      CommunityProvider().add(newCommunity);
    } else {
      throw "Error while creating the community, please retry later";
    }
  }
}
