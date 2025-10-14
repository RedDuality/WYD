import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/service/event/event_storage_service.dart';

class CachedMediaProvider extends ChangeNotifier {
  static final CachedMediaProvider _instance = CachedMediaProvider._internal();

  factory CachedMediaProvider() {
    return _instance;
  }

  CachedMediaProvider._internal();

  final Map<String, Map<AssetEntity, bool>> _cachedImagesMap = {};

  Map<AssetEntity, bool>? get(String hash) => _cachedImagesMap[hash];

  void set(String eventHash, Set<AssetEntity> media) {
    EventStorageService.setHasCachedMedia(eventHash, true);

    var mediaMap = {for (var asset in media) asset: true};
    _cachedImagesMap[eventHash] = mediaMap;
    notifyListeners();
  }

  void remove(String eventHash) {
    EventStorageService.setHasCachedMedia(eventHash, false);

    _cachedImagesMap[eventHash] = {};
    notifyListeners();
  }

  void select(String eventHash, AssetEntity assetEntity) {
    _cachedImagesMap[eventHash]![assetEntity] = true;
  }

  void unselect(String eventHash, AssetEntity assetEntity) {
    _cachedImagesMap[eventHash]![assetEntity] = false;
  }
}
