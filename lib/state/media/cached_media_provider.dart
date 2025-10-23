import 'dart:async';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/media/cached_media_storage.dart';

class CachedMediaProvider extends ChangeNotifier {
  final CachedMediaStorage _storage = CachedMediaStorage();

  Map<AssetEntity, bool> _cachedImagesMap = {};

  StreamSubscription<String>? _eventMediaSubscription;

  CachedMediaProvider(String eventHash) {
    load(eventHash);
    _eventMediaSubscription = _storage.updates.listen((eventHash) {
      load(eventHash);
    });
  }

  Map<AssetEntity, bool>? get() => _cachedImagesMap;

  /// Load from DB
  Future<void> load(String eventHash) async {
    final media = await _storage.getMedia(eventHash);
    _cachedImagesMap = media;
    notifyListeners();
  }

  /// Save a set of assets for an event
  Future<void> set(String eventHash, Set<AssetEntity> media) async {
    await _storage.addMedia(eventHash, media);
    _cachedImagesMap = {for (var asset in media) asset: true};
    notifyListeners();
  }

  /// Remove all assets for an event
  Future<void> removeAll(String eventHash) async {
    await _storage.removeAllMedia(eventHash);
    _cachedImagesMap = {};
    EventStorageService.setHasCachedMedia(eventHash, false);
    notifyListeners();
  }

  /// Mark asset as selected
  Future<void> select(String eventHash, AssetEntity asset) async {
    await _storage.updateSelection(eventHash, asset, true);
    _cachedImagesMap[asset] = true;
    notifyListeners();
  }

  /// Mark asset as unselected
  Future<void> unselect(String eventHash, AssetEntity asset) async {
    await _storage.updateSelection(eventHash, asset, false);
    _cachedImagesMap[asset] = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventMediaSubscription?.cancel();
    super.dispose();
  }
}
