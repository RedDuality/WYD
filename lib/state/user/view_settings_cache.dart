import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/users/view_settings.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/state/user/view_settings_storage.dart';

class ViewSettingsCache extends ChangeNotifier {
  final ViewSettingsStorage _storage = ViewSettingsStorage();
  late final StreamSubscription<ViewSettings> _settingsChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Set<String> _confirmedViewProfiles = {UserCache().getCurrentProfileId()};
  final Set<String> _sharedViewProfiles = {UserCache().getCurrentProfileId()};

  ViewSettingsCache() {
    _settingsChannel = _storage.updates.listen((settings) {
      _set(settings);
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Set<String> getProfiles(bool confirmed) {
    return confirmed ? _confirmedViewProfiles : _sharedViewProfiles;
  }

  void _set(ViewSettings settings) {
    if (settings.viewerId != UserCache().getCurrentProfileId()) {
      return;
    }

    _updateSet(_confirmedViewProfiles, settings.viewedId, settings.viewConfirmed);
    _updateSet(_sharedViewProfiles, settings.viewedId, settings.viewShared);

    notifyListeners();
  }

  void _updateSet(Set<String> set, String id, bool shouldContain) {
    if (shouldContain) {
      set.add(id);
    } else {
      set.remove(id);
    }
  }

  Future<void> reset() async {
    final currentProfileId = UserCache().getCurrentProfileId();
    final settingsList = await ViewSettingsStorage().getByViewerId(currentProfileId);

    _confirmedViewProfiles
      ..clear()
      ..addAll([
        currentProfileId,
        ...settingsList.where((s) => s.viewConfirmed).map((s) => s.viewedId),
      ]);

    _sharedViewProfiles
      ..clear()
      ..addAll([
        currentProfileId,
        ...settingsList.where((s) => s.viewShared).map((s) => s.viewedId),
      ]);

    notifyListeners();
  }

  void clearAll() {
    _confirmedViewProfiles.clear();
    _sharedViewProfiles.clear();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _settingsChannel.cancel();
    super.dispose();
  }
}
