import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

//helper class to the eventDetail component
class BlobProvider extends ChangeNotifier {
  static final BlobProvider _instance = BlobProvider._internal();

  BlobProvider._internal();

  factory BlobProvider() {
    return _instance;
  }

  //current shown event
  String eventHash = "";

  List<String> imageHashes = [];

  List<AssetEntity> cachedImages = [];

  //if last image has been deleted
  bool cacheHashBeenModified = false;

  void initialize({String? hash, List<String>? imageHashes, List<AssetEntity>? cachedImages}) {
    cacheHashBeenModified = false;

    eventHash = hash ?? "";
    this.imageHashes = imageHashes ?? [];
    this.cachedImages = cachedImages ?? [];

    notifyListeners();
  }

  void close() {
    cachedImages.clear();
    imageHashes.clear();
    eventHash = "";
    cacheHashBeenModified = false;
  }

  bool exists() {
    return eventHash.isNotEmpty;
  }

  bool isCurrentEvent(String eventHash) {
    return this.eventHash == eventHash;
  }

  void updateImageHashes(List<String> imageHashes) {
    this.imageHashes = imageHashes;
    notifyListeners();
  }


  void setCachedImages(List<AssetEntity> cachedNewImages) {
    cacheHashBeenModified = true;
    cachedImages = cachedNewImages;
    notifyListeners();
  }

  void removeCachedImage(AssetEntity image) {
    cacheHashBeenModified = true;
    cachedImages.remove(image);
    notifyListeners();
  }

  void clearCachedImages() {
    cachedImages.clear();
    cacheHashBeenModified = false;
    notifyListeners();
  }
}
