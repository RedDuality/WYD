import 'dart:async';
import 'package:wyd_front/API/Profile/profile_api.dart';
import 'package:wyd_front/service/profile/profile_storage_service.dart';

class ProfileRetrieveService {
  ProfileRetrieveService._privateConstructor();

  static final ProfileRetrieveService _instance = ProfileRetrieveService._privateConstructor();

  factory ProfileRetrieveService() => _instance;

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
      ProfileStorageService.addProfiles(dtos);
    } finally {
      _isFetching = false;
    }
  }

  Future<void> retrieve(String profileId) async {
    _queue.add(profileId);
    _scheduleFetch();
  }
}
