import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/model/enum/community_type.dart';
import 'package:wyd_front/state/user_provider.dart';
import 'package:wyd_front/widget/search_user_page.dart';

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
      body: Selector<UserProvider, List<Community>>(
        selector: (context, userProvider) => userProvider.user!.communities,
        builder: (context, communities, child) {
          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              var community = communities[index];
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
    final user = mainGroup.users
        .where((u) => u.mainProfileId != UserProvider().getMainProfileId())
        .first;
    return ListTile(
      title: Text(user.userName),
    );
  }

  Widget _buildSingleGroupTile(Community community) {
    return ListTile(
      title: Text(community.name),
    );
  }

  Widget _buildMultiGroupTile(Community community) {
    return ExpansionTile(
      title: Text(community.name),
      children: community.groups.map((group) {
        return ListTile(
          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(group.name),
          ),
        );
      }).toList(),
    );
  }

}
