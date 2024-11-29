
import 'package:flutter/material.dart';
import 'package:wyd_front/widget/user_search_bar.dart';

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
        title: const Text('Groups'),
      ),
      body: const Column(
        children: <Widget>[
          UserSearchBar()
        ],
      ),
    );
  }
}
