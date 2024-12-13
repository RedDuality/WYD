import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/DTO/create_community_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/community_service.dart';
import 'package:wyd_front/service/model/user_service.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({super.key});

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {
  List<Profile> _filteredUsers = [];
  bool _isLoading = false;
  Timer? _debounce;

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _fetchItems(value);
    });
  }

  Future<void> _fetchItems(String tag) async {
    setState(() {
      _isLoading = true;
    });
    var users = await ProfileService().searchByTag(tag);

    setState(() {
      if (users != null) {
        _filteredUsers = users;
      }
      _isLoading = false;
    });
  }

  Widget _buildList() {
    return ListView(
      shrinkWrap: true,
      children: _filteredUsers.map((Profile value) {
        return ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value.name),
              TextButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add"),
                onPressed: () {
                  CreateCommunityDto community = CreateCommunityDto(users: [value]);

                  CommunityService().create(community);
                },
              ),
            ],
          ),
          onTap: () {
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Search User"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search User',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _onSearchChanged(value);
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
          if (!_isLoading && _filteredUsers.isNotEmpty) _buildList(),
        ],
      ),
    );
  }
}
