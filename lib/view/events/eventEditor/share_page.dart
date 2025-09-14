import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/group.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/event/event_view_service.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class SharePage extends StatefulWidget {
  final String eventTitle;
  final String eventHash;

  const SharePage({super.key, required this.eventTitle, required this.eventHash});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  Set<int> selectedGroups = {};
  String currentProfileHash = UserProvider().getCurrentProfileHash();

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
              child: Consumer<CommunityProvider>(
                builder: (context, communityProvider, child) {
                  return Column(
                    children: communityProvider.communities!
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
                      EventViewService.shareToGroups(widget.eventHash, selectedGroups);
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
    final mainGroup = community.groups.first;
    final profileHash = mainGroup.profileHashes.where((p) => p != currentProfileHash).first;
    // TODO unite this in the profileTile
    // Listens for changes to a specific profile and rebuilds only when that profile is updated.
    final profile = context.select<ProfilesProvider, Profile?>(
      (provider) => provider.get(profileHash),
    );
    ProfileService().retrieveOrSynchProfile(profile, profileHash);
    if (profile == null) {
      return ListTile(title: Text('Loading...'));
    } else {
      return ListTile(
          leading: CircleAvatar(backgroundImage: ImageProviderService.getImageProvider()),
          title: Text(profile.name),
          trailing: _groupCheckBox(mainGroup));
    }
  }

  Widget _buildSingleGroupCommunityTile(Community community) {
    final group = community.groups.first;
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: ImageProviderService.getImageProvider(),
        ),
        title: Text(community.name),
        trailing: _groupCheckBox(group));
  }

  Widget _buildMultiGroupCommunityTile(Community community) {
    return ExpansionTile(
      leading: CircleAvatar(backgroundImage: ImageProviderService.getImageProvider()),
      title: Text(community.name),
      children: community.groups.map((group) {
        return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
                leading: CircleAvatar(backgroundImage: ImageProviderService.getImageProvider()),
                title: Text(group.name),
                trailing: _groupCheckBox(group)));
      }).toList(),
    );
  }

  Widget _groupCheckBox(Group group) {
    return Checkbox(
      value: selectedGroups.contains(group.id),
      onChanged: (bool? value) {
        setState(() {
          if (value == true) {
            selectedGroups.add(group.id);
          } else {
            selectedGroups.remove(group.id);
          }
        });
      },
    );
  }
}
