import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/state/media/media_storage.dart';

class MediaCache extends ChangeNotifier {
  final MediaStorage _storage = MediaStorage();

  // current event images
  Map<AssetEntity, bool> _cachedImagesMap = {};

  late final StreamSubscription<(String eventId, bool deleted)> _eventMediaUpdateChannel;
  late final StreamSubscription<(AssetEntity asset, bool selected)> _eventMediaSelectionChannel;
  late final StreamSubscription<void> _clearAllChannel;

  MediaCache(String eventId) {
    load(eventId);
    _eventMediaUpdateChannel = _storage.updates.listen((updateData) {
      final removeAction = updateData.$2;
      if (removeAction) {
        removeAll(updateData.$1);
      } else {
        load(updateData.$1);
      }
    });

    _eventMediaSelectionChannel = _storage.selections.listen((selectionData) {
      select(selectionData.$1, selectionData.$2);
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
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

  void clearAll(){
    _cachedImagesMap.clear();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _eventMediaSelectionChannel.cancel();
    _eventMediaUpdateChannel.cancel();
    super.dispose();
  }
}
