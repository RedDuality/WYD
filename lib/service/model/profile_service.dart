import 'dart:async';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/API/Profile/update_profile_request_dto.dart';
import 'package:wyd_front/model/profile.dart';
import 'package:wyd_front/state/profile/profiles_provider.dart';

class ProfileService {
  ProfileService._privateConstructor();

  static final ProfileService _instance = ProfileService._privateConstructor();

  factory ProfileService() => _instance;

  final Set<String> _queue = {};
  Timer? _timer;
  bool _isFetching = false;

  static const Duration debounceDuration = Duration(milliseconds: 100);

  void _scheduleFetch() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer(debounceDuration, () async {
      await _fetchProfiles();
      if (_queue.isNotEmpty) {
        _scheduleFetch(); // Reschedule if new requests came in during fetch
      }
    });
  }

  Future<void> _fetchProfiles() async {
    if (_isFetching || _queue.isEmpty) return;

    _isFetching = true;
    final hashes = _queue.toList();
    _queue.clear();

    try {
      final dtos = await ProfileAPI().retrieveFromHashes(hashes);
      final profiles = dtos.map((d) => Profile.fromDto(d)).toList();
      ProfilesProvider().addAll(profiles);
    } finally {
      _isFetching = false;
    }
  }

  void retrieveOrSynchProfile(Profile? profile, String hash) {
    final anHourAgo = DateTime.now().subtract(Duration(hours: 1));
    if (profile == null || profile.updatedAt.isBefore(anHourAgo)) {
      _queue.add(hash);
      _scheduleFetch();
    }
  }

  Future<void> updateProfile(UpdateProfileRequestDto updateDto) async {
    await ProfileAPI().updateProfile(updateDto);
  }

  Future<List<Profile>> searchByTag(String searchTag) async {
    final dtos = await ProfileAPI().searchByTag(searchTag);
    return dtos.map((d) => Profile.fromDto(d)).toList();
  }
}
