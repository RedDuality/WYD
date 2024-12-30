import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class BlobProvider extends ChangeNotifier {
  // Private static instance variable
  static final BlobProvider _instance = BlobProvider._internal();

  // Private constructor
  BlobProvider._internal();

  // Public factory method to provide access to the instance
  factory BlobProvider() {
    return _instance;
  }

  String? hash;

  List<String> imageHashes = [];

  List<AssetEntity> cachedImages = [];

  bool cacheHashBeenModified = false;

  void initialize(
      {String? hash,
      List<String>? imageHashes,
      List<AssetEntity>? cachedImages}) {
    cacheHashBeenModified = false;

    this.hash = hash;
    this.imageHashes = imageHashes ?? [];
    this.cachedImages = cachedImages ?? [];

    notifyListeners();
  }

  void close() {
    cachedImages.clear();
    hash = "";
  }

  bool exists() {
    return hash != null;
  }

  void addCachedImages(List<AssetEntity> cachedNewImages) {
    cachedImages.addAll(cachedNewImages);
    notifyListeners();
  }

  void removeNewImage(AssetEntity image) {
    cacheHashBeenModified = true;
    cachedImages.remove(image);
    notifyListeners();
  }

  void clearNewImages() {
    cachedImages.clear();
    cacheHashBeenModified = true;

    notifyListeners();
  }

  void updateImageHashes(List<String> imageHashes,
      {bool keepCachedImages = true}) {
    this.imageHashes = imageHashes;
    if (!keepCachedImages) {
      cachedImages.clear();
      cacheHashBeenModified = false;
    }
    notifyListeners();
  }
}
