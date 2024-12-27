import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum ImageSize { mini, midi, big }

class ImageService {
  bool _isValid(String? url) {
    return url != null && Uri.parse(url).hasAbsolutePath;
  }

  String _getSizeUrl(String? url, size) {
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

  Map<String, String> _getHeaders() {
    return {HttpHeaders.accessControlAllowOriginHeader: "*"};
  }

  Image _wydLogo(ImageSize size) {
    return Image.asset(_getSizeUrl('assets/images/logoimage.png', size));
  }

  Text _failedToLoadImage() {
    return Text('Failed to load image');
  }

  ImageProvider getImageProvider(
      {String? imageUrl, ImageSize size = ImageSize.mini, Widget? onError}) {
    if (_isValid(imageUrl)) {
      return NetworkImage(_getSizeUrl(imageUrl, size));
    } else {
      return AssetImage(_getSizeUrl('assets/images/logoimage.png', size));
    }
  }

  Image getImage(
      {String? imageUrl, ImageSize size = ImageSize.big, Widget? onError}) {
    if (_isValid(imageUrl)) {
      return Image.network(
        _getSizeUrl(imageUrl, size),
        headers: _getHeaders(),
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          return onError ?? _failedToLoadImage();
        },
      );
    } else {
      return _wydLogo(size);
    }
  }

  Image getEventImage(String eventHash, String blobHash) {
    String? blobUrl = '${dotenv.env['BLOB_URL']}';
    final url = '$blobUrl${eventHash.toLowerCase()}/${blobHash.toLowerCase()}';
    return getImage(imageUrl: url);
  }
}
