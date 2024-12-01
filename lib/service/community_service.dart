import 'dart:convert';

import 'package:wyd_front/API/community_api.dart';
import 'package:wyd_front/model/DTO/create_community_dto.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/state/user_provider.dart';

class CommunityService {

  Future<void> create(CreateCommunityDto community) async {
    var response = await CommunityAPI().create(community);

    if (response.statusCode == 200) {
      Community newCommunity = Community.fromJson(jsonDecode(response.body));

      UserProvider().user!.communities.add(newCommunity);
    } else {
      throw "Error while creating the community, please retry later";
    }
  }
  
}
