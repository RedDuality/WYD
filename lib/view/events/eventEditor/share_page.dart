import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/API/Community/share_event_request_dto.dart';
import 'package:wyd_front/model/community/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/service/event/event_actions_service.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/state/community/community_cache.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/view/profiles/tiles/profile_tile.dart';

class SharePage extends StatefulWidget {
  final String eventTitle;
  final String eventId;

  const SharePage({super.key, required this.eventTitle, required this.eventId});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  Set<ShareGroupIdentifierDto> selectedGroups = {};
  String currentProfileHash = UserCache().getCurrentProfileId();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 3, 8, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.eventTitle,
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Annulla'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Consumer<CommunityCache>(
                builder: (context, communityProvider, child) {
                  return Column(
                    children: communityProvider.communities
                        .map((community) => _buildCommunityTile(context, community))
                        .toList(),
                  );
                },
              ),
            ),
          ),
          if (selectedGroups.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      EventActionsService.shareToGroups(widget.eventId, selectedGroups);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Condividi'),
                  )
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunityTile(BuildContext context, Community community) {
    switch (community.type) {
      case CommunityType.personal:
        return _buildPersonalCommunityTile(context, community);
      case CommunityType.singlegroup:
        return _buildSingleGroupCommunityTile(community);
      case CommunityType.community:
        return _buildMultiGroupCommunityTile(community);
    }
  }

  Widget _buildPersonalCommunityTile(BuildContext context, Community community) {
    final group = community.groups.first;
    final profileHash = community.otherProfileId!;

    return ProfileTile(
      profileId: profileHash,
      type: ProfileTileType.view,
      trailing: _groupCheckBox(group.id, community.id),
    );
  }

  Widget _buildSingleGroupCommunityTile(Community community) {
    final group = community.groups.first;
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: ImageProviderService.getImageProvider(),
        ),
        title: Text(community.name!),
        trailing: _groupCheckBox(group.id, community.id));
  }

  Widget _buildMultiGroupCommunityTile(Community community) {
    return ExpansionTile(
      leading: CircleAvatar(backgroundImage: ImageProviderService.getImageProvider()),
      title: Text(community.name!),
      children: community.groups.map((group) {
        return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
                leading: CircleAvatar(backgroundImage: ImageProviderService.getImageProvider()),
                title: Text(group.name!),
                trailing: _groupCheckBox(group.id, community.id)));
      }).toList(),
    );
  }

  Widget _groupCheckBox(String groupId, String communityId) {
    var addDto = ShareGroupIdentifierDto(communityId: communityId, groupId: groupId);
    return Checkbox(
      value: selectedGroups.contains(addDto),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedGroups.add(addDto);
          } else {
            selectedGroups.remove(addDto);
          }
        });
      },
    );
  }
}
