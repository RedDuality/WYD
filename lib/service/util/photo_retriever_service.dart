import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/model/event_service.dart';
import 'package:wyd_front/service/util/permission_service.dart';
import 'package:wyd_front/state/event_provider.dart';

class PhotoRetrieverService {
  static Future<List<AssetEntity>> retrieveImagesByTime(
      DateTime? start, DateTime? end) async {
    // Request permissions to access photos before proceeding
    await PermissionService.requestGalleryPermissions();

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

    return await album.getAssetListPaged(
      page: 0,
      size: await album.assetCountAsync,
    );
  }

  Future<void> retrieveShootedPhotos(String eventHash) async {
    var event = EventProvider().findEventByHash(eventHash);
    if (event != null) {
      var photosDuringEvent = await retrieveImagesByTime(
          event.startTime!.toUtc(), event.endTime!.toUtc());
      if (photosDuringEvent.isNotEmpty) {
        EventService.setCachedImages(event, photosDuringEvent);
      }
    }
  }

  Future<void> testRetrieveShootedPhotos(String eventHash) async {
    var event = EventProvider().findEventByHash(eventHash);
    debugPrint("PHOTOS ${(event != null)}");
    if (event != null) {
      /*var photosDuringEvent = await ImageService().retrieveImagesByTime(
          event.startTime!.toUtc(), event.endTime!.toUtc());
      */
      List<AssetEntity> photosDuringEvent =
          await PhotoRetrieverService.retrieveImagesByTime(
              DateTime.now().subtract(Duration(days: 1)), DateTime.now());

      debugPrint("PHOTOS ${photosDuringEvent.length.toString()}");
      if (photosDuringEvent.isNotEmpty) {
        debugPrint(photosDuringEvent.length.toString());
        EventService.setCachedImages(event, photosDuringEvent);
      }
    }
  }

  // Save DateTime to SharedPreferences
  Future<void> _saveDateTime({DateTime? time}) async {
    time = time ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('savedDateTime', time.toUtc().toIso8601String());
  }

  // Load DateTime from SharedPreferences
  Future<DateTime> _loadLastCheckedTime() async {
    final prefs = await SharedPreferences.getInstance();
    final dateTimeString = prefs.getString('savedDateTime');
    if (dateTimeString != null) {
      try {
        return DateTime.parse(dateTimeString).toLocal();
      } catch (e) {
        debugPrint("error while converting the date");
      }
    }
    return DateTime.now().toLocal();
  }

  void addTimer(Event event) {
    var endTime = event.endTime!.add(Duration(minutes: 1));
    Timer(endTime.difference(DateTime.now()), () async {
      await timerCallback(event);
    });
  }

  Future<void> timerCallback(Event event) async {
    //endTime has not been changed
    if (event.endTime!.difference(DateTime.now()).inMinutes <= 3) {
      await PhotoRetrieverService().retrieveShootedPhotos(event.hash);
      _saveDateTime();
    }
  }

  void init() async {
    DateTime lastCheckedTime = await _loadLastCheckedTime();
    var now = DateTime.now();

    //including the ones that ends now
    var eventsNotChecked = EventProvider().allEvents.whereType<Event>().where(
        (event) =>
            !event.endTime!.isAfter(now) &&
            event.endTime!.isAfter(lastCheckedTime));

    var eventsToCheckInTheFuture = EventProvider()
        .allEvents
        .whereType<Event>()
        .where((event) => event.endTime!.isAfter(now));

    for (Event event in eventsNotChecked) {
      PhotoRetrieverService().retrieveShootedPhotos(event.hash);
    }

    for (Event event in eventsToCheckInTheFuture) {
      addTimer(event);
    }

    _saveDateTime(time: now);
  }
}
