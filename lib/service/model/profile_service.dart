import 'dart:async';
import 'package:wyd_front/API/profile_api.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profiles_provider.dart';

class ProfileService {
  ProfileService._privateConstructor();

  static final ProfileService _instance = ProfileService._privateConstructor();

  factory ProfileService() {
    return _instance;
  }

  final Set<String> queue = {};
  Timer? _timer;

  void _startTimer(Function fun) {
    if (_timer == null || !_timer!.isActive) {
      _timer = Timer.periodic(Duration(milliseconds: 33), (timer) {
        fun();
      });
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  Future<List<Profile>?> searchByTag(String searchTag) async {
    return ProfileAPI().searchByTag(searchTag);
  }

  Future<void> updateProfile(Profile profile) async {
    await ProfileAPI().updateProfile(profile);
    ProfilesProvider().addAll([profile]);
  }

  _retrieveProfiles() async {
    if (queue.isNotEmpty) {
      var request = ProfileAPI().retrieveFromHashes(queue.toList());
      queue.clear();
      final profiles = await request;
      ProfilesProvider().addAll(profiles);
    } else {
      _stopTimer();
    }
  }

  synchProfile(Profile? profile, String hash) {
    var anHourAgo = DateTime.now().subtract(Duration(hours: 1));
    if (profile == null || profile.lastUpdatedTime.isBefore(anHourAgo)) {
      queue.add(hash);
      _startTimer(_retrieveProfiles);
    }
  }
}
