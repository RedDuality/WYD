import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class DevicePermissionService {
  static Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.photos,
      Permission.notification,
    ].request();

    if (statuses[Permission.photos]!.isGranted) {
      debugPrint("Gallery access granted!");
    } else if (statuses[Permission.photos]!.isDenied) {
      debugPrint("Gallery access denied.");
      if (await Permission.photos.isPermanentlyDenied) {
        debugPrint("Permission is permanently denied. Opening settings...");
        openAppSettings();
      }
    }

    if (statuses[Permission.notification]!.isGranted) {
      debugPrint("Notification access granted!");
    } else if (statuses[Permission.notification]!.isDenied) {
      debugPrint("Notification access denied.");
      if (await Permission.notification.isPermanentlyDenied) {
        debugPrint("Permission is permanently denied. Opening settings...");
        openAppSettings();
      }
    }
  }

  static Future<void> requestGalleryPermissions() async {
    // Request permission to access photos
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      debugPrint("Gallery access granted!");
    } else if (status.isDenied) {
      debugPrint("Gallery access denied.");
      if (await Permission.photos.isPermanentlyDenied) {
        debugPrint("Permission is permanently denied. Opening settings...");
        openAppSettings();
      }
    }
  }
}
