import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/DTO/blob_data.dart';

enum ImageSize { mini, midi, big }

class ImageService {
  Future<void> requestPermissions() async {
    // Request permission to access photos
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      debugPrint("Gallery access granted!");
    } else if (status.isDenied) {
      debugPrint("Gallery access denied.");
      // Check if permission is denied permanently and guide the user to settings
      if (await Permission.photos.isPermanentlyDenied) {
        debugPrint("Permission is permanently denied. Opening settings...");
        openAppSettings(); // Opens app settings so the user can manually enable the permission
      }
    } else if (status.isPermanentlyDenied) {
      // The user has permanently denied the permission, show an explanation
      debugPrint("Gallery access permanently denied. Opening settings...");
      openAppSettings(); // Open app settings for the user to manually enable
    }
  }

  Future<BlobData?> _compressImage(Uint8List imageData) async {
    if (imageData.isNotEmpty) {
      try {
        // Compress the image data
        final compressedImageData = await FlutterImageCompress.compressWithList(
          imageData,
          minWidth: 403,
          quality: 85,
        );

        return BlobData(data: compressedImageData, mimeType: "image/jpeg");
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return null;
  }

  Future<List<XFile>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    return await picker.pickMultiImage();
  }

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

/*
  Future<List<BlobData>> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();

    if (images.isNotEmpty) {
      List<BlobData> compressedImages = [];
      for (XFile image in images) {
        final Uint8List imageData = await image.readAsBytes();
        BlobData? data = await _compressImage(imageData);
        if (data != null) {
          compressedImages.add(data);
        }
      }
      return compressedImages;
    }
    return [];
  }
*/
  Future<List<BlobData>> retrieveImages(DateTime? start, DateTime? end) async {
    // Request permissions to access photos before proceeding
    await requestPermissions();

    if (start == null || end == null) {
      throw ArgumentError("Both start and end dates must be provided.");
    }

    // Define the filter options for retrieving media
    final FilterOptionGroup optionGroup = FilterOptionGroup(
      createTimeCond: DateTimeCond(
        min: start,
        max: end,
      ),
      orders: [
        OrderOption(type: OrderOptionType.createDate, asc: false)
      ], // Order by creation date descending
    );

    // Get the list of media albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: optionGroup,
    );

    // Filter the list to find the main camera folder
    AssetPathEntity? album;
    try {
      album =
          albums.firstWhere((album) => album.name.toLowerCase() == "camera");
    } catch (e) {
      debugPrint("No Camera album was found");
      return [];
    }

    final List<AssetEntity> media = await album.getAssetListPaged(
      page: 0,
      size: await album.assetCountAsync,
    );

    final List<BlobData> result = [];
    for (final asset in media) {
      final Uint8List? data = await asset.originBytes;
      if (data != null) {
        var blobData = await _compressImage(data);
        if (blobData != null) {
          result.add(
              blobData); // You can replace this with your compression function
        }
      }
    }
    return result;
  }

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
    return Image.asset(
      _getSizeUrl('assets/images/logoimage.png', size),
      scale: 2,
      fit: BoxFit.contain,
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

  Image getImage(
      {String? imageUrl, ImageSize size = ImageSize.big, Widget? onError}) {
    if (_isValid(imageUrl)) {
      return Image.network(
        _getSizeUrl(imageUrl, size),
        fit: BoxFit.contain,
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
