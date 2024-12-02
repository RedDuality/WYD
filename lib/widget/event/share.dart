import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/model/group.dart';
import 'package:wyd_front/service/event_service.dart';
import 'package:wyd_front/service/information_service.dart';
import 'package:wyd_front/state/user_provider.dart';

class Share extends StatefulWidget {
  final Event event;

  const Share({super.key, required this.event});

  @override
  State<Share> createState() => _ShareState();
}

class _ShareState extends State<Share> {
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
              Expanded(child: Text(widget.event.title)),
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
            child: Selector<UserProvider, List<Community>>(
              selector: (context, userProvider) =>
                  userProvider.user!.communities,
              builder: (context, communities, child) {
                return Column(
                  children: communities
                      .map((community) => _buildCommunityTile(community))
                      .toList(),
                );
              },
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () async {
                  EventService().shareToGroups(widget.event, selectedGroups);
                  Navigator.of(context).pop();
                },
                child: const Text('Condividi'),
              ),
              TextButton(
                onPressed: () async {
                  String? siteUrl = '${dotenv.env['SITE_URL']}';
                  await Clipboard.setData(ClipboardData(
                      text: "$siteUrl#/shared?event=${widget.event.hash}"));

                  if (context.mounted) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    InformationService()
                        .showInfoSnackBar(context, "Link copiato con successo");
                  }
                },
                child: const Text('Copia il link'),
              ),
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
    final user = mainGroup.users
        .where((u) => u.mainProfileId != UserProvider().getMainProfileId())
        .first;
    return ListTile(
        title: Text(user.userName), trailing: _groupCheckBox(mainGroup));
  }

  Widget _buildSingleGroupCommunityTile(Community community) {
    final group = community.groups.first;
    return ListTile(title: Text(group.name), trailing: _groupCheckBox(group));
  }

  Widget _buildMultiGroupCommunityTile(Community community) {
    return ExpansionTile(
      title: Text(community.name),
      children: community.groups.map((group) {
        return ListTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text(group.name),
            ),
            trailing: _groupCheckBox(group));
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
