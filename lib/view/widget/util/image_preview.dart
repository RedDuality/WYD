import 'package:flutter/material.dart';

enum ImageSize { mini, midi, big }

class ImagePreview extends StatelessWidget {
  final String? imageUrl;
  final ImageSize size;

  const ImagePreview({super.key, this.imageUrl, this.size = ImageSize.big});

  String getUrl(String? link) {
    String url = link ?? 'assets/images/logoimage.png';
    String suffix;

    switch (size) {
      case ImageSize.mini:
        suffix = '_mini';
        break;
      case ImageSize.midi:
        suffix = '_midi';
        break;
      case ImageSize.big:
      default:
        suffix = '';
        break;
    }

    // Find the last dot in the URL to insert the suffix before the extension
    int dotIndex = url.lastIndexOf('.');
    if (dotIndex != -1) {
      return url.substring(0, dotIndex) + suffix + url.substring(dotIndex);
    } else {
      // If there's no extension, just append the suffix
      return url + suffix;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeInImage.assetNetwork(
      placeholder: getUrl(null),
      image: getUrl(imageUrl),
      fit: BoxFit.cover,
    );
  }

  ImageProvider getImageProvider() {
    return NetworkImage(getUrl(imageUrl));
  }
}
