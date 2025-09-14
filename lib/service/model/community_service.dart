import 'package:wyd_front/API/Community/community_api.dart';
import 'package:wyd_front/API/Community/create_community_dto.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class CommunityService {

  Future<void> retrieveCommunities() async {
    var hash = UserProvider().getCurrentProfileHash();
    var communities = await CommunityAPI().retrieveCommunities(hash);

    CommunityProvider().setRange(communities);
  }


  Future<void> create(CreateCommunityDto community) async {
    var newCommunity = await CommunityAPI().create(community);

    CommunityProvider().add(newCommunity);

  }
}
