import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';
import 'package:wyd_front/state/media/cached_media_storage.dart';

class CachedMediaProvider extends ChangeNotifier {
  static final CachedMediaProvider _instance = CachedMediaProvider._internal();
  factory CachedMediaProvider() => _instance;
  CachedMediaProvider._internal();

  final CachedMediaStorage _storage = CachedMediaStorage();

  /// In‑memory cache (mirrors DB for fast access)
  final Map<String, Map<AssetEntity, bool>> _cachedImagesMap = {};

  Map<AssetEntity, bool>? get(String eventHash) => _cachedImagesMap[eventHash];

  /// Load from DB into memory
  Future<void> load(String eventHash) async {
    final media = await _storage.getMedia(eventHash);
    _cachedImagesMap[eventHash] = media;
    notifyListeners();
  }

  /// Save a set of assets for an event
  Future<void> set(String eventHash, Set<AssetEntity> media) async {
    await _storage.setMedia(eventHash, media);
    _cachedImagesMap[eventHash] = {for (var asset in media) asset: true};
    EventStorageService.setHasCachedMedia(eventHash, true);
    notifyListeners();
  }

  /// Remove all assets for an event
  Future<void> remove(String eventHash) async {
    await _storage.removeMedia(eventHash);
    _cachedImagesMap[eventHash] = {};
    EventStorageService.setHasCachedMedia(eventHash, false);
    notifyListeners();
  }

  /// Mark asset as selected
  Future<void> select(String eventHash, AssetEntity asset) async {
    await _storage.updateSelection(eventHash, asset, true);
    _cachedImagesMap[eventHash]?[asset] = true;
    notifyListeners();
  }

  /// Mark asset as unselected
  Future<void> unselect(String eventHash, AssetEntity asset) async {
    await _storage.updateSelection(eventHash, asset, false);
    _cachedImagesMap[eventHash]?[asset] = false;
    notifyListeners();
  }
}
