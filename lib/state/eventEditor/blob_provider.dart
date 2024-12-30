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

  String hash = "";

  List<String> imageHashes = [];

  List<AssetEntity> cachedImages = [];

  bool cacheHashBeenModified = false;

  void initialize(
      {String? hash,
      List<String>? imageHashes,
      List<AssetEntity>? cachedImages}) {
    cacheHashBeenModified = false;

    this.hash = hash ?? "";
    this.imageHashes = imageHashes ?? [];
    this.cachedImages = cachedImages ?? [];

    notifyListeners();
  }

  void close() {
    cachedImages.clear();
    hash = "";
  }

  bool exists() {
    return hash.isNotEmpty;
  }

  void addCachedImages(List<AssetEntity> cachedNewImages,
      {required String hash}) {
    if (this.hash == hash) {
      cachedImages.addAll(cachedNewImages);
      notifyListeners();
    }
  }

  void removeCachedImage(AssetEntity image, {required String hash}) {
    if (this.hash == hash) {
      cacheHashBeenModified = true;
      cachedImages.remove(image);
      notifyListeners();
    }
  }

  void clearCachedImages({required String hash}) {
    if (this.hash == hash) {
      cachedImages.clear();
      cacheHashBeenModified = true;
      notifyListeners();
    }
  }

  void updateImageHashes(List<String> imageHashes, {required String hash}) {
    if (this.hash == hash) {
      this.imageHashes = imageHashes;
      notifyListeners();
    }
  }

  void uploadedCachedImages(List<String> imageHashes, {required String hash}) {
    if (this.hash == hash) {
      cachedImages.clear();
      cacheHashBeenModified = true;
      this.imageHashes = imageHashes;
      notifyListeners();
    }
  }
}
