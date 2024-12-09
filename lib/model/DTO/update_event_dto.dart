
import 'package:wyd_front/model/DTO/blob_data.dart';
import 'package:wyd_front/model/event.dart';

class UpdateEventDto {
  Event updatedEvent;
  List<BlobData>? newImages;

  UpdateEventDto({
    required this.updatedEvent,
    this.newImages,
  });

  Map<String, dynamic> toJson() {
    return {
      'updatedEvent': updatedEvent.toJson(),
      'newImages': newImages?.map((image) => image.toJson()).toList(),
    };
  }
}

