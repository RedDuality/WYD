import 'package:flutter/foundation.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/service/model/profile_service.dart';
import 'package:wyd_front/state/profiles_provider.dart';

class ProfilesNotifier extends ChangeNotifier {
  final Map<String, ProfileNotifier> _notifiers = {};

  ProfileNotifier getNotifier(String profileHash) {
    var notifier = _notifiers.putIfAbsent(profileHash, () => ProfileNotifier());
    _retrieveProfile(profileHash, notifier);
    return notifier;
  }

  void updateNotifiers(Iterable<Profile> profiles) {
    for (var profile in profiles) {
      _notifiers[profile.hash]?.setProfile(profile);
    }
  }

  void _retrieveProfile(String hash, ProfileNotifier notifier) {
    var profile = ProfilesProvider().get(hash);
    if (profile != null) {
      notifier.setProfile(profile);
    } else {
      ProfileService().retrieveProfile(hash, this);
    }
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
