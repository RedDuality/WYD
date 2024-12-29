import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/event.dart';



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

  void initialize({String? hash, List<String>? imageHashes,   List<AssetEntity>? cachedImages}) {
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

  
  void addCachedImages(Event event) {
    if (event.hash == hash) {
      cachedImages.addAll(event.cachedNewImages);
      notifyListeners();
    }
  }

  void removeNewImage(AssetEntity image) {
    cachedImages.remove(image);
    notifyListeners();
  }

  void clearNewImages() {
    cachedImages.clear();
    notifyListeners();
  }

  void updateImageHashes(List<String> imageHashes){
    this.imageHashes = imageHashes;
    notifyListeners();
  }

}
