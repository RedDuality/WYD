import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/state/media/cached_media_storage.dart';

class CachedMediaCache extends ChangeNotifier {
  final CachedMediaStorage _storage = CachedMediaStorage();

  // current event images
  Map<AssetEntity, bool> _cachedImagesMap = {};

  late final StreamSubscription<(String, bool)> _eventMediaUpdateSubscription;
  late final StreamSubscription<(AssetEntity, bool)> _eventMediaSelectionSubscription;

  CachedMediaCache(String eventId) {
    load(eventId);
    _eventMediaUpdateSubscription = _storage.updates.listen((updateData) {
      final removeAction = updateData.$2;
      if (removeAction) {
        removeAll(updateData.$1);
      } else {
        load(updateData.$1);
      }
    });

    _eventMediaSelectionSubscription = _storage.selections.listen((selectionData) {
      select(selectionData.$1, selectionData.$2);
    });
  }

  Map<AssetEntity, bool>? get() => _cachedImagesMap;

  /// Load from DB
  Future<void> load(String eventId) async {
    final media = await _storage.getMedia(eventId);
    _cachedImagesMap = media;
    notifyListeners();
  }

  /// Remove all assets for an event
  void removeAll(String eventId) {
    _cachedImagesMap = {};
    notifyListeners();
  }

  /// Mark asset as selected
  void select(AssetEntity asset, bool hasBeenSelected) {
    _cachedImagesMap[asset] = hasBeenSelected;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventMediaSelectionSubscription.cancel();
    _eventMediaUpdateSubscription.cancel();
    super.dispose();
  }
}
