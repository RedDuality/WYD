import 'package:flutter/material.dart';
import 'package:wyd_front/model/community.dart';

class CommunityProvider extends ChangeNotifier {
  // Private static instance
  static final CommunityProvider _instance = CommunityProvider._internal();

  // Factory constructor returns the singleton instance
  factory CommunityProvider() {
    return _instance;
  }

  List<Community> _communities = [];

  // Private named constructor
  CommunityProvider._internal() {
    _communities = [];
  }

  List<Community>? get communities => _communities;

  void add(Community community) {
    _communities.add(community);
    notifyListeners();
  }

  void setRange(List<Community> communities) {
    _communities = communities;
    notifyListeners();
  }

  void addRange(List<Community> communities) {
    _communities.addAll(communities);
    notifyListeners();
  }

  void updateGroupTitle(int communityId, int groupIndex, String name) {
    final community = _communities.firstWhere((c) => c.id == communityId);
    community.groups[groupIndex].name = name;
    notifyListeners();
  }
}
