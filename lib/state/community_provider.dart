import 'package:flutter/material.dart';
import 'package:wyd_front/model/community.dart';

class CommunityProvider extends ChangeNotifier {
  static final CommunityProvider _instance = CommunityProvider._internal();

  factory CommunityProvider() {
    return _instance;
  }

  List<Community> _communities = [];

  CommunityProvider._internal() {
    _communities = [];
  }

  List<Community> get communities => _communities;

  Community? find(String id) {
    return _communities.firstWhere((c) => c.id == id);
  }

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

  void updateGroupTitle(String communityId, int groupIndex, String name) {
    final community = find(communityId)!;
    community.groups[groupIndex].name = name;
    notifyListeners();
  }
}
