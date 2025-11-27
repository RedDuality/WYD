import 'package:wyd_front/API/Media/media_read_response_dto.dart';

import '../enum/media_visibility.dart';

class Media {
  String eventId;
  String? extension;
  String? name;
  DateTime? creationDate;
  MediaVisibility? visibility;
  String? url;
  DateTime? validUntil;
  String? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Media && other.eventId == eventId;
  }

  @override
  int get hashCode => eventId.hashCode;

  Media({
    required this.eventId,
    this.extension,
    this.name,
    this.creationDate,
    this.visibility,
    this.url,
    this.validUntil,
    this.error,
  });

  factory Media.fromDto(MediaReadResponseDto dto) {
    return Media(
      eventId: dto.hash,
      extension: dto.extension!,
      name: dto.name!,
      creationDate: dto.creationDate!,
      visibility: dto.visibility!,
      url: dto.url,
      validUntil: dto.validUntil,
      error: dto.error,
    );
  }
}
