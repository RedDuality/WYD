import 'dart:async';

import 'package:flutter/material.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];
  bool _isLoading = false;
  Timer? _debounce;
    final LayerLink _layerLink = LayerLink();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      _fetchItems(_searchController.text);
    });
  }

  Future<void> _fetchItems(String tag) async {
    // Simulate a call to the backend function UserService().FromTag(String tag)
    // Replace this with your actual backend call
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _filteredItems = ['Item1', 'Item2', 'Item3', 'Item4']
          .where((item) => item.contains(tag))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CompositedTransformTarget(
              link: _layerLink,
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search User',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ),
          if (_isLoading) CircularProgressIndicator(),
          if (!_isLoading && _filteredItems.isNotEmpty) _buildDropdown(),
        ],
      ),
    );
  }

  Widget _buildDropdown() {
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: const Offset(0, 40), // Adjust the offset as needed
      child: Material(
        elevation: 4.0,
        child: SizedBox(
          width:
              MediaQuery.of(context).size.width - 16, // Adjust width as needed
          child: ListView(
            shrinkWrap: true,
            children: _filteredItems.map((String value) {
              return ListTile(
                title: Text(value),
                onTap: () {
                  // Handle dropdown item selection
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
