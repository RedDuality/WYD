import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wyd_front/model/event.dart';
import 'package:wyd_front/service/util/permission_service.dart';
import 'package:wyd_front/state/event/calendar_view_event_controller.dart';
import 'package:wyd_front/state/eventEditor/cached_media_provider.dart';

class MediaAutoSelectService {
  static void init() async {
    if (!kIsWeb) {
      DateTime lastCheckedTime = await _loadLastCheckedTime();
      var now = DateTime.now();

      //including the ones that ends right now
      var eventsNotChecked = CalendarViewEventController()
          .allEvents
          .whereType<Event>()
          .where((event) => !event.endTime!.isAfter(now) && event.endTime!.isAfter(lastCheckedTime));

      var eventsToCheckInTheFuture =
          CalendarViewEventController().allEvents.whereType<Event>().where((event) => event.endTime!.isAfter(now));

      for (Event event in eventsNotChecked) {
        retrieveShootedPhotos(event.eventHash);
      }

      for (Event event in eventsToCheckInTheFuture) {
        addTimer(event);
      }

      _saveDateTime(time: now);
    }
  }

  static void addTimer(Event event) {
    if (!kIsWeb) {
      var endTime = event.endTime!.add(Duration(minutes: 1));
      Timer(endTime.difference(DateTime.now()), () async {
        await timerCallback(event);
      });
    }
  }

  // Save DateTime to SharedPreferences
  static Future<void> _saveDateTime({DateTime? time}) async {
    time = time ?? DateTime.now();
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('savedDateTime', time.toUtc().toIso8601String());
  }

  // Load DateTime from SharedPreferences
  static Future<DateTime> _loadLastCheckedTime() async {
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

  static Future<void> timerCallback(Event event) async {
    //endTime has not been changed
    if (event.endTime!.difference(DateTime.now()).inMinutes <= 3) {
      await retrieveShootedPhotos(event.eventHash);
      _saveDateTime();
    }
  }

  static Future<List<AssetEntity>> retrieveImagesByTime(DateTime? start, DateTime? end) async {
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

  static Future<void> mockRetrieveShootedPhotos(String eventHash) async {
    var event = CalendarViewEventController().findEventByHash(eventHash);
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
        CachedMediaProvider().set(event.eventHash, mockAssetEntities.toSet());
      }
    }
  }

  static Future<void> retrieveShootedPhotos(String eventHash) async {
    var event = CalendarViewEventController().findEventByHash(eventHash);
    if (event != null) {
      var photosDuringEvent = await retrieveImagesByTime(event.startTime!.toUtc(), event.endTime!.toUtc());

      if (photosDuringEvent.isNotEmpty) {
        CachedMediaProvider().set(event.eventHash, photosDuringEvent.toSet());
      }
    }
  }
}
