import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class MediaData {
  String tempId;
  DateTime creationDate;
  String mimeType;
  Uint8List data;

  MediaData({
    required this.creationDate,
    required this.mimeType,
    required this.data,
  }) : tempId = const Uuid().v4();
}
