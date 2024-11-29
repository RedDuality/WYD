import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/community.dart';
import 'package:wyd_front/state/user_provider.dart';

class GroupList extends StatelessWidget {
  const GroupList({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Selector<UserProvider, List<Community>>(
        selector: (context, userProvider) => userProvider.user!.communities,
        builder: (context, communities, child) {
          return ListView.builder(
            itemCount: communities.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(communities[index].name),
              );
            },
          );
        },
      ),
    );
  }
}
