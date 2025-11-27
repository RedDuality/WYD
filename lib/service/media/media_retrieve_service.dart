import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:wyd_front/model/events/event.dart';
import 'package:wyd_front/service/util/device_permission_service.dart';
import 'package:wyd_front/state/event/event_storage.dart';
import 'package:wyd_front/state/media/cached_media_cache.dart';
import 'package:wyd_front/state/media/cached_media_storage.dart';

class MediaRetrieveService {
  static Future<void> retrieveShootedPhotos(Event event) async {
    var photosDuringEvent = await _retrieveImagesByTime(event.startTime!.toUtc(), event.endTime!.toUtc());

    if (photosDuringEvent.isNotEmpty) {
      CachedMediaStorage().setCachedMedia(event.id, photosDuringEvent.toSet());
    }
  }

  static Future<void> mockRetrieveShootedPhotos(String eventId, CachedMediaCache provider) async {
    var event = await EventStorage().getEventByHash(eventId);
    if (event != null) {
      var mockAssetEntities = List.generate(
        10,
        (index) => AssetEntity(
          id: 'mock_id_$index',
          typeInt: 1,
          width: 735,
          height: 735,
        ),
      );

      if (mockAssetEntities.isNotEmpty) {
        CachedMediaStorage().setCachedMedia(event.id, mockAssetEntities.toSet());
      }
    }
  }

  static Future<List<AssetEntity>> _retrieveImagesByTime(DateTime? start, DateTime? end) async {
    // Request permissions to access photos before proceeding
    await DevicePermissionService.requestGalleryPermissions();

    if (start == null || end == null) {
      throw ArgumentError("Both start and end dates must be provided.");
    }

    // Define the filter options for retrieving media
    final FilterOptionGroup optionGroup = FilterOptionGroup(
      createTimeCond: DateTimeCond(
        min: start,
        max: end,
      ),
      orders: [OrderOption(type: OrderOptionType.createDate, asc: false)],
    );

    // Get the list of media albums
    final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
      type: RequestType.image,
      filterOption: optionGroup,
    );

    // Filter the list to find the main camera folder
    AssetPathEntity? album;
    try {
      album = albums.firstWhere((album) => album.name.toLowerCase() == "camera");
    } catch (e) {
      debugPrint("No \"Camera\" album was found or no photos where taken during this event ");
      return [];
    }

    return await album.getAssetListPaged(
      page: 0,
      size: await album.assetCountAsync,
    );
  }
}
