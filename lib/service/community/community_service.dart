import 'package:wyd_front/API/Community/community_api.dart';
import 'package:wyd_front/API/Community/create_community_request_dto.dart';
import 'package:wyd_front/model/community/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/state/community_storage.dart';

class CommunityService {
  Future<void> retrieveCommunities() async {
    var communityDtos = await CommunityAPI().retrieveCommunities();

    var communities = communityDtos.map((c) => Community.fromDto(c)).toList();
    CommunityStorage().setRange(communities);
  }

  Future<void> create(CreateCommunityRequestDto community) async {
    var newCommunityDto = await CommunityAPI().create(community);

    var newCommunity = Community.fromDto(newCommunityDto);
    CommunityStorage().add(newCommunity);
  }

  bool hasPersonalByProfileId(String profileId){
    return CommunityStorage().communities.where((c) => c.type == CommunityType.personal && c.otherProfileId == profileId).isNotEmpty;
  } 
}
