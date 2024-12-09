import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/view/widget/search_user_page.dart';
import 'package:wyd_front/view/widget/util/image_preview.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Search"),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SearchUserPage(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Start from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end)
                        .chain(CurveTween(curve: curve));
                    var offsetAnimation = animation.drive(tween);

                    return SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CommunityProvider>(
        builder: (context, communityProvider, child) {
          return ListView.builder(
            itemCount: communityProvider.communities!.length,
            itemBuilder: (context, index) {
              var community = communityProvider.communities![index];
              return _buildCommunityTile(community);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommunityTile(Community community) {
    switch (community.type) {
      case CommunityType.personal:
        return _buildPersonalTile(community);
      case CommunityType.singlegroup:
        return _buildSingleGroupTile(community);
      case CommunityType.community:
        return _buildMultiGroupTile(community);
      default:
        return Container();
    }
  }

  Widget _buildPersonalTile(Community community) {
    final mainGroup = community.groups.first;
    final profile = mainGroup.profiles
        .where((p) => p.id != UserProvider().getCurrentProfileId())
        .first;
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: const ImagePreview(
          size: ImageSize.mini,
        ).getImageProvider(),
      ),
      title: Text(profile.name),
    );
  }

  Widget _buildSingleGroupTile(Community community) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: const ImagePreview(
          size: ImageSize.mini,
        ).getImageProvider(),
      ),
      title: Text(community.name),
    );
  }

  Widget _buildMultiGroupTile(Community community) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundImage: const ImagePreview(
          size: ImageSize.mini,
        ).getImageProvider(),
      ),
      title: Text(community.name),
      children: community.groups.map((group) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: const ImagePreview(
                size: ImageSize.mini,
              ).getImageProvider(),
            ),
            title: Text(group.name),
          ),
        );
      }).toList(),
    );
  }
}
