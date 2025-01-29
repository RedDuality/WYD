import 'dart:async';
import 'package:wyd_front/API/profile_api.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profiles_provider.dart';
import 'package:wyd_front/view/profiles/profiles_notifier.dart';

class ProfileService {
  ProfileService._privateConstructor();

  static final ProfileService _instance = ProfileService._privateConstructor();

  factory ProfileService() {
    return _instance;
  }

  final Set<String> _profileQueue = {};
  final Set<ProfilesNotifier?> _containers = {};
  Timer? _timer;

  void _startTimer(Function fun) {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        fun();
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _localUpdate(Iterable<Profile> profiles) {
    ProfilesProvider().addAll(profiles.toList());
    for (var container in _containers) {
      container?.updateNotifiers(profiles);
    }
  }

  Future<List<Profile>?> searchByTag(String searchTag) async {
    return ProfileAPI().searchByTag(searchTag);
  }

  Future<List<Profile>> retrieveProfiles(Set<String> hashes) async {
    final profiles = await ProfileAPI().retrieveFromHashes(hashes.toList());
    ProfilesProvider().addAll(profiles);
    return profiles;
  }

  Future<void> updateProfile(Profile profile) async {
    await ProfileAPI().updateProfile(profile);
    _localUpdate([profile]);
        
  }

  _getProfiles() async {
    if (_profileQueue.isNotEmpty) {
      var profiles = await ProfileService().retrieveProfiles(_profileQueue);
      _localUpdate(profiles);

      _profileQueue.clear();
    } else {
      _stopTimer();
    }
  }

  void retrieveProfile(String hash, ProfilesNotifier container) {
    _containers.add(container);
    _profileQueue.add(hash);
    _startTimer(_getProfiles);
  }
}
