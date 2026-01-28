import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/service/media/image_provider_service.dart';
import 'package:wyd_front/state/community/community_storage.dart';
import 'package:wyd_front/view/masks/gallery/mask_gallery.dart';
import 'package:wyd_front/view/profiles/tiles/profile_tile.dart';
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
                  pageBuilder: (context, animation, secondaryAnimation) => const SearchProfilePage(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    const begin = Offset(1.0, 0.0); // Start from right
                    const end = Offset.zero;
                    const curve = Curves.easeInOut;

                    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
      body: Consumer<CommunityStorage>(
        builder: (context, communityProvider, child) {
          return ListView.builder(
            itemCount: communityProvider.communities.length,
            itemBuilder: (context, index) {
              var community = communityProvider.communities[index];
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
        final profileId = community.getProfileHash();
        return ProfileTile(
            profileId: profileId, type: ProfileTileType.view, trailing: _galleryButton(context, profileId));
      case CommunityType.singlegroup:
        return _groupTile(title: community.name!);
      case CommunityType.community:
        return _expansionCommunityTile(title: community.name!, children: community.groups);
    }
  }

  Widget _groupTile({required String title, String? imageUrl}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: ImageProviderService.getImageProvider(imageUrl: imageUrl),
      ),
      title: Text(title),
      //trailing: _galleryButton(),
    );
  }

  Widget _galleryButton(BuildContext context, String profileId) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: IconButton(
        icon: const Icon(Icons.calendar_month),
        tooltip: "view agenda",
        onPressed: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MaskGallery(profileId: profileId),
            ),
          ),
        },
      ),
    );
  }

  Widget _expansionCommunityTile({
    required String title,
    required Iterable children,
    String? imageUrl,
  }) {
    return ExpansionTile(
      leading: CircleAvatar(
        backgroundImage: ImageProviderService.getImageProvider(imageUrl: imageUrl),
      ),
      title: Text(title),
      children: children.map((child) {
        return Padding(padding: const EdgeInsets.only(left: 16.0), child: _groupTile(title: child.name));
      }).toList(),
    );
  }
}
