import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/profile/profile_storage_service.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';

class ProfilesProvider extends ChangeNotifier {
  final ProfileStorage _storage = ProfileStorage();
  StreamSubscription<Profile>? _profileSubscription;

  ProfilesProvider() {
    _profileSubscription = _storage.updates.listen((profile) {
      set(profile.id, profile);
    });
  }

  final Map<String, Profile> _profiles = {};

  Profile? get(String id) {
    var result = _profiles[id];

    if (result == null) {
      unawaited(_checkStorage(id));
    }

    return result;
  }

  Future<void> _checkStorage(String profileId) async {
    var profile = await ProfileStorageService.retrieve(profileId);
    if (profile != null) {
      set(profileId, profile);
    }
  }

  void set(String id, Profile profile) {
    _profiles[id] = profile;
    notifyListeners();
  }

  void addAll(List<Profile> profiles) {
    for (final profile in profiles) {
      _profiles[profile.id] = profile;
    }
    notifyListeners();
  }
    @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }
}
