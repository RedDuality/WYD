import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/profiles/profile.dart';
import 'package:wyd_front/service/profile/profile_storage_service.dart';
import 'package:wyd_front/state/profile/profile_storage.dart';

class ProfileCache extends ChangeNotifier {
  final ProfileStorage _storage = ProfileStorage();

  late final StreamSubscription<Profile> _profileChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Map<String, Profile> _profiles = {};

  ProfileCache() {
    _profileChannel = _storage.updates.listen((profile) {
      _set(profile.id, profile);
    });
    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

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
      _set(profileId, profile);
    }
  }

  void _set(String id, Profile profile) {
    _profiles[id] = profile;
    notifyListeners();
  }

  void clearAll() {
    _profiles.clear();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _profileChannel.cancel();
    super.dispose();
  }
}
