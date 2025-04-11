import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:image/image.dart' as img;

enum ImageSize { mini, midi, big }

class ImageService {
  Future<BlobData?> _compressImage(Uint8List imageData) async {
    if (imageData.isNotEmpty) {
      try {
        // Attempt to decode the image to determine the format
        final image = img.decodeImage(imageData);

        if (image == null) {
          throw Exception('Failed to decode image');
        }

        // Compress the image data
        final compressedImageData = await FlutterImageCompress.compressWithList(
          imageData,
          minWidth: 403,
          quality: 85,
          format: CompressFormat.jpeg, // Default to jpeg compression
        );

        // Dynamically determine the MIME type
        String mimeType = "image/jpeg"; // Default mimeType
        if (image.hasAlpha) {
          mimeType = "image/png"; // If image has alpha channel, use PNG
        }

        return BlobData(data: compressedImageData, mimeType: mimeType);
      } catch (e) {
        debugPrint("Compression failed: $e");
        //TODO check this, was failing on firefox

        // If compression fails, return original image with proper MIME type
        String mimeType = "image/jpeg"; // Default mimeType
        try {
          final image = img.decodeImage(imageData);
          if (image != null) {
            if (image.hasAlpha) {
              mimeType = "image/png"; // If image has alpha channel, use PNG
            }
          }
        } catch (e) {
          // Handle case where decoding also fails
          debugPrint("Failed to decode image: $e");
        }

        return BlobData(data: imageData, mimeType: mimeType);
      }
    }
    return null;
  }

  Future<List<BlobData>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    var files = await picker.pickMultiImage();
    List<BlobData> compressedImages = [];
    if (files.isNotEmpty) {
      for (XFile image in files) {
        final Uint8List imageData = await image.readAsBytes();
        BlobData? data = await _compressImage(imageData);
        if (data != null) {
          compressedImages.add(data);
        }
      }
    }
    return compressedImages;
  }

/*
  ImageProvider getImageFromXFile(XFile file) {
    return NetworkImage(file.path);
  }

  Future<List<BlobData>> dataFromXFile(List<XFile> files) async {
    List<BlobData> compressedImages = [];
    for (XFile image in files) {
      final Uint8List imageData = await image.readAsBytes();
      BlobData? data = await _compressImage(imageData);
      if (data != null) {
        compressedImages.add(data);
      }
    }
    return compressedImages;
  }
*/

  ImageProvider<Object> getImageFromAssetEntity(AssetEntity entity) {
    return AssetEntityImageProvider(entity);
  }

  Future<List<BlobData>> dataFromAssetEntities(
      List<AssetEntity> entities) async {
    List<BlobData> compressedImages = [];
    for (AssetEntity asset in entities) {
      final Uint8List? data = await asset.originBytes;
      if (data != null) {
        var blobData = await _compressImage(
          data,
        );
        if (blobData != null) {
          compressedImages.add(blobData);
        }
      }
    }
    return compressedImages;
  }

  bool _isValid(String? url) {
    return url != null && Uri.parse(url).hasAbsolutePath && !url.endsWith('/');
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
    return Image.asset(
      _getSizeUrl('assets/images/logoimage.png', size),
      fit: BoxFit.cover,
    );
  }

  Text _failedToLoadImage() {
    return Text('Failed to load image');
  }

  ImageProvider getImageProvider(
      {String? imageUrl, ImageSize size = ImageSize.big, Widget? onError}) {
    if (_isValid(imageUrl)) {
      return NetworkImage(_getSizeUrl(imageUrl, size), headers: _getHeaders());
    } else {
      return AssetImage(_getSizeUrl('assets/images/logoimage.png', size));
    }
  }

  ImageProvider getEventImage(String eventHash, String blobHash) {
    String? blobUrl = '${dotenv.env['BLOB_URL']}';
    final url = '$blobUrl${eventHash.toLowerCase()}/${blobHash.toLowerCase()}';
    return getImageProvider(imageUrl: url);
  }

  ImageProvider getProfileImage(String profileHash, String blobHash) {
    String? blobUrl = '${dotenv.env['BLOB_URL']}';
    final url =
        '$blobUrl"p"${profileHash.toLowerCase()}/${blobHash.toLowerCase()}';
    return getImageProvider(imageUrl: url);
  }

  Image getImage(
      {String? imageUrl, ImageSize size = ImageSize.big, Widget? onError}) {
    if (_isValid(imageUrl)) {
      return Image.network(
        _getSizeUrl(imageUrl, size),
        fit: BoxFit.cover,
        scale: 2,
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
}
