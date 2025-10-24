import 'dart:core';
import 'dart:io';
import 'dart:typed_data';
import 'package:exif/exif.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/blob_data.dart';
import 'package:wyd_front/service/media/mimetype_service.dart';

class MediaSelectionService {
  // cache is made of assetEntities
  static Future<List<MediaData>> dataFromCache(List<AssetEntity> entities) async {
    List<MediaData> compressedImages = [];
    for (AssetEntity asset in entities) {
      final Uint8List? data = await asset.originBytes;

      var blob = await _createBlobData(asset.createDateTime, data!, mimeType: asset.mimeType);

      if (blob != null) {
        compressedImages.add(blob);
      }
    }
    return compressedImages;
  }

  static Future<List<MediaData>> selectMedia() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: MimetypeService().getAllowedExtensions(),
      allowMultiple: true,
    );

    if (result == null) {
      return []; // User cancelled the picker
    }

    return await _getFilesMediaData(result);
  }

  static Future<List<MediaData>> _getFilesMediaData(FilePickerResult pickerResult) async {
    List<MediaData> blobs = [];
    for (PlatformFile platformFile in pickerResult.files) {
      MediaData? blob;
      if (platformFile.path != null) {
        final Uint8List? fileData = platformFile.bytes;
        if (fileData != null) {
          final String? mimeType =
              platformFile.extension != null ? MimetypeService.getMimeTypeFromExtension(platformFile.extension!) : null;

          DateTime creationDate = await _getMediaCreationDate(platformFile.path!);

          blob = await _createBlobData(creationDate, fileData, mimeType: mimeType);
        }
      }
      if (blob != null) {
        blobs.add(blob);
      } else {
        //error
        debugPrint('Skipping a file because blob creation failed.');
      }
    }
    return blobs;
  }

  static Future<DateTime> _getMediaCreationDate(String path) async {
    // --- Step 1: Try to resolve AssetEntity from path ---
    try {
      final asset = await _resolveAssetEntityFromPath(path);
      if (asset != null) {
        return asset.createDateTime;
      }
    } catch (_) {
      // ignore PhotoManager errors
    }

    // --- Step 2: Try EXIF metadata ---
    try {
      final bytes = await File(path).readAsBytes();
      final tags = await readExifFromBytes(bytes);

      if (tags.containsKey('Image DateTime')) {
        final dateString = tags['Image DateTime']!.printable;
        final parsed = DateTime.tryParse(dateString.replaceFirst(':', '-', 2));
        if (parsed != null) {
          return parsed;
        }
      }
    } catch (_) {
      // ignore EXIF errors
    }

    // --- Step 3: Fallback to FileStat ---
    try {
      final stat = await FileStat.stat(path);
      return stat.changed; // always non-null
    } catch (_) {
      // ignore FileStat errors
    }

    // --- Step 4: Last resort ---
    return DateTime.now();
  }

  /// Helper: try to find an AssetEntity from a file path
  static Future<AssetEntity?> _resolveAssetEntityFromPath(String path) async {
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.common, // images + videos
    );

    for (final album in albums) {
      final int count = await album.assetCountAsync;
      final assets = await album.getAssetListRange(start: 0, end: count);
      for (final asset in assets) {
        final file = await asset.file;
        if (file != null && file.path == path) {
          return asset;
        }
      }
    }
    return null;
  }

  static Future<MediaData?> _createBlobData(DateTime creationDate, Uint8List data, {String? mimeType}) async {
    // First, check if the input data is empty
    if (data.isEmpty) {
      debugPrint('Input data is empty. Cannot create blob.');
      return null;
    }

    Uint8List finalData = data;
    mimeType ??= MimetypeService.getMimeType(data);

    if (mimeType != null && mimeType.startsWith('image')) {
      final Uint8List? compressedData = await _compressImage(data);
      if (compressedData != null && compressedData.isNotEmpty) {
        finalData = compressedData;
      } else {
        debugPrint("Image compression failed or resulted in empty data.");
        return null; // Return null if compression fails
      }
    }

    return MediaData(
      creationDate: creationDate,
      mimeType: mimeType!, // MimeType should not be null here if we proceed
      data: finalData,
    );
  }

  static Future<Uint8List?> _compressImage(Uint8List imageData) async {
    if (imageData.isNotEmpty) {
      try {
        final compressedImageData = await FlutterImageCompress.compressWithList(
          imageData,
          quality: 75,
        );
        return compressedImageData;
      } catch (e) {
        debugPrint("Compression failed: $e");
      }
    }
    return null;
  }
}
