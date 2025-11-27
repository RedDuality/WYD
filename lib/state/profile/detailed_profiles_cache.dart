import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/detailed_profile.dart';
import 'package:wyd_front/service/profile/detailed_profile_storage_service.dart';
import 'package:wyd_front/state/profile/detailed_profile_storage.dart';

class DetailedProfileCache extends ChangeNotifier {
  final DetailedProfileStorage _storage = DetailedProfileStorage();

  late final StreamSubscription<DetailedProfile> _profileChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Map<String, DetailedProfile> _profiles = {};

  DetailedProfileCache() {
    _profileChannel = _storage.updates.listen((profile) {
      _set(profile.id, profile);
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  DetailedProfile? get(String id) {
    var result = _profiles[id];
    if (result == null) {
      unawaited(_checkStorage(id));
    }
    return result;
  }

  Future<void> _checkStorage(String profileId) async {
    var profile = await DetailedProfileStorageService.retrieve(profileId);
    if (profile != null) {
      _set(profileId, profile);
    }
  }

  void _set(String id, DetailedProfile profile) {
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
