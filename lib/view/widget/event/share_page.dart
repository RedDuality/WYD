import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/group.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/state/user_provider.dart';

class SharePage extends StatefulWidget {
  final String eventTitle;
  final String eventHash;

  const SharePage({super.key, required this.eventTitle, required this.eventHash});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  Set<int> selectedGroups = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
          child: Row(
            children: [
              Expanded(child: Text(widget.eventTitle)),
              TextButton(
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
                      .map((community) => _buildCommunityTile(community))
                      .toList(),
                );
              },
            ),
          ),
        ),
        if(selectedGroups.isNotEmpty)
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  EventService().shareToGroups(widget.eventHash, selectedGroups);
                  Navigator.of(context).pop();
                },
                child: const Text('Condividi'),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityTile(Community community) {
    switch (community.type) {
      case CommunityType.personal:
        return _buildPersonalCommunityTile(community);
      case CommunityType.singlegroup:
        return _buildSingleGroupCommunityTile(community);
      case CommunityType.community:
        return _buildMultiGroupCommunityTile(community);
      default:
        return Container();
    }
  }

  Widget _buildPersonalCommunityTile(Community community) {
    final mainGroup = community.groups.first;
    final profile = mainGroup.profiles
        .where((p) => p.id != UserProvider().getCurrentProfileId())
        .first;
    return ListTile(
        leading: CircleAvatar(
            backgroundImage: ImageService().getImageProvider()),
        title: Text(profile.name),
        trailing: _groupCheckBox(mainGroup));
  }

  Widget _buildSingleGroupCommunityTile(Community community) {
    final group = community.groups.first;
    return ListTile(
        leading: CircleAvatar(
          backgroundImage: ImageService().getImageProvider(),
        ),
        title: Text(group.name),
        trailing: _groupCheckBox(group));
  }

  Widget _buildMultiGroupCommunityTile(Community community) {
    return ExpansionTile(
      leading: CircleAvatar(
          backgroundImage: ImageService().getImageProvider()),
      title: Text(community.name),
      children: community.groups.map((group) {
        return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: ListTile(
                leading: CircleAvatar(
                    backgroundImage:
                        ImageService().getImageProvider()),
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
