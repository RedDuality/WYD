import 'package:flutter/material.dart';

enum ImageSize { mini, midi, big }

class ImageProviderService {

  static ImageProvider? getProfileImage(String profileHash, String blobHash, {ImageSize size = ImageSize.big}) {
    return wydLogoImageProvider(size);
  }

  static ImageProvider getImageProvider({String? imageUrl, ImageSize size = ImageSize.big}) {
    return wydLogoImageProvider(size);
  }
  static Image getImage({ImageSize size = ImageSize.mini}){
    return Image(image: wydLogoImageProvider(size));
  }

  static ImageProvider wydLogoImageProvider(ImageSize size) {
    String path;
    switch (size) {
      case ImageSize.mini:
        path = 'assets/images/logoimage_mini.png';
        break;
      case ImageSize.big:
      default:
        path = 'assets/images/logoimage.png';
        break;
    }

    return AssetImage(path);
  }
}
