import 'dart:async';

import 'package:calendar_view/calendar_view.dart';
import 'package:wyd_front/state/media/media_flag_storage.dart';

class MediaFlagCache extends EventController {
  final MediaFlagStorage _storage = MediaFlagStorage();

  late final StreamSubscription<(String eventId, bool deleted)> _updatesChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Set<String> _flags = {};

  MediaFlagCache() {
    _initialize();
    _updatesChannel = _storage.mediaFlagsUpdates.listen((data) {
      data.$2 ? delete(data.$1) : addFlag(data.$1);
    });
    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Future<void> _initialize() async {
    final allFlags = await _storage.getAll();
    _flags
      ..clear()
      ..addAll(allFlags);
    notifyListeners();
  }

  void addFlag(String eventId) {
    _flags.add(eventId);
    notifyListeners();
  }

  void delete(String eventId) {
    _flags.remove(eventId);
    notifyListeners();
  }

  bool hasCachedMedia(String eventId) {
    return _flags.contains(eventId);
  }

  void clearAll() {
    _flags.clear();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _updatesChannel.cancel();
    super.dispose();
  }
}
