import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/DTO/user_dto.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/service/user_service.dart';

class UserSearchBar extends StatefulWidget {
  const UserSearchBar({super.key});

  @override
  State<UserSearchBar> createState() => _UserSearchBarState();
}

class _UserSearchBarState extends State<UserSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<UserDto> _filteredUsers = [];
  bool _isLoading = false;
  Timer? _debounce;
  final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _filteredUsers = [];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (_searchController.text.isNotEmpty) {
        _fetchItems(_searchController.text);
      }
    });
  }

  Future<void> _fetchItems(String tag) async {
    setState(() {
      _isLoading = true;
    });
    var users = await UserService().searchByTag(tag);

    setState(() {
      if(users != null){
        _filteredUsers = users;
      }
      _isLoading = false;
    });
  }

  Widget _buildDropdown() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 40), // Adjust the offset as needed
      child: Center(
        child: Material(
          elevation: 4.0,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 64,
            child: ListView(
              shrinkWrap: true,
              children: _filteredUsers.map((UserDto value) {
                return ListTile(
                  title: Text(value.userName),
                  onTap: () {
                    // Handle dropdown item selection
                  },
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CompositedTransformTarget(
            link: _layerLink,
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              decoration: const InputDecoration(
                labelText: 'Search User',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ),
        if (_isLoading) const CircularProgressIndicator(),
        if (!_isLoading && _filteredUsers.isNotEmpty) _buildDropdown(),
      ],
    );
  }
}
