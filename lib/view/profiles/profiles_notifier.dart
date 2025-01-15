import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/state/profiles_provider.dart';

class ProfilesNotifier extends ChangeNotifier {
  final Map<String, ProfileNotifier> _notifiers = {};
  final Set<String> _profileQueue = {};
  Timer? _timer;

  ProfileNotifier getNotifier(String hash) {
    var notifier = _notifiers.putIfAbsent(hash, () => ProfileNotifier());
    requestProfile(hash);
    return notifier;
  }

  void requestProfile(String hash) {
    var profile = ProfilesProvider().get(hash);
    if (profile == null) {
      _profileQueue.add(hash);
      _startTimer();
    } else {
      _notifiers[hash]?.setProfile(profile);
    }
  }

  void _startTimer() {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(milliseconds: 300), (timer) {
        _fetchProfilesInBulk();
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _fetchProfilesInBulk() async {
    if (_profileQueue.isNotEmpty) {
      ProfileService().retrieveProfiles(_profileQueue.toList()).then(
        (profiles) {
          for (var profile in profiles) {
            _notifiers[profile.hash]?.setProfile(profile);
          }
        },
      );

      _profileQueue.clear();
    } else {
      _stopTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class ProfileNotifier extends ChangeNotifier {
  Profile? _profile;

  Profile? get profile => _profile;

  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }
}
