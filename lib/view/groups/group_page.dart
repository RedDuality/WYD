import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/service/util/image_service.dart';
import 'package:wyd_front/state/community_provider.dart';
import 'package:wyd_front/view/profiles/profile_tile.dart';
import 'package:wyd_front/view/widget/header.dart';
import 'package:wyd_front/view/groups/search_profile_page.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(
        title: "Groups",
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.search),
            label: const Text("Search"),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const SearchProfilePage(),
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
              return _buildCommunityTile(context, community);
            },
          );
        },
      ),
    );
  }

  Widget _buildCommunityTile(BuildContext context, Community community) {
    switch (community.type) {
      case CommunityType.personal:
        return ProfileTile(
            profileHash: community.getProfileHash(),
            type: ProfileTileType.view);
      case CommunityType.singlegroup:
        return avatarTile(title: community.name);
      case CommunityType.community:
        return expansionAvatarTile(
            title: community.name, children: community.groups);
      default:
        return Container();
    }
  }

  Widget avatarTile({required String title, String? imageUrl}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: ImageService.getImageProvider(imageUrl: imageUrl),
      ),
      title: Text(title),
    );
  }

  Widget expansionAvatarTile({
    required String title,
    required Iterable children,
    String? imageUrl,
  }) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundImage: ImageService.getImageProvider(imageUrl: imageUrl),
      ),
      title: Text(title),
      children: children.map((child) {
        return Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: avatarTile(title: child.name));
      }).toList(),
    );
  }
}
