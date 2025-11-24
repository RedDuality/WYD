import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/view_settings.dart';
import 'package:wyd_front/state/user/user_cache.dart';
import 'package:wyd_front/state/user/view_settings_storage.dart';

class ViewSettingsCache extends ChangeNotifier {
  final ViewSettingsStorage _storage = ViewSettingsStorage();
  StreamSubscription<ViewSettings>? _settingsSubscription;

  ViewSettingsCache() {
    _settingsSubscription = _storage.updates.listen((settings) {
      _set(settings);
    });
  }

  final Set<String> _confirmedViewProfiles = {UserCache().getCurrentProfileId()};
  final Set<String> _sharedViewProfiles = {UserCache().getCurrentProfileId()};

  Set<String> getProfiles(bool confirmed) {
    return confirmed ? _confirmedViewProfiles : _sharedViewProfiles;
  }

  void _updateSet(Set<String> set, String id, bool shouldContain) {
    if (shouldContain) {
      set.add(id);
    } else {
      set.remove(id);
    }
  }

  void _set(ViewSettings settings) {
    if (settings.viewerId != UserCache().getCurrentProfileId()) {
      return;
    }

    _updateSet(_confirmedViewProfiles, settings.viewedId, settings.viewConfirmed);
    _updateSet(_sharedViewProfiles, settings.viewedId, settings.viewShared);

    notifyListeners();
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

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }
}
