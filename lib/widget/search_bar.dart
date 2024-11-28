import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  const SearchBar({super.key});

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<String> _filteredItems = [];
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
          _filteredItems = [];
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
        if (!_isLoading && _filteredItems.isNotEmpty) _buildDropdown(),
      ],
    );
  }
}
