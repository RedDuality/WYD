import 'package:flutter/material.dart';

enum ImageSize { mini, midi, big }

String getUrl(String? url, size) {
  if (url == null || url.isEmpty) {
    return 'assets/images/logoimage.png'; // Return asset path for placeholder
  }
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

class ImageService {
  ImageProvider<Object> getImage(String? imageUrl, final ImageSize size) {
    final isValid =
        imageUrl != null ? Uri.parse(imageUrl).hasAbsolutePath : false;

    if (isValid) {
      return NetworkImage(getUrl(imageUrl, size));
    } else {
      return AssetImage(getUrl('assets/images/logoimage.png', size));
    }
  }
}
