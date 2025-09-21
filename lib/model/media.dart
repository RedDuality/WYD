import 'package:wyd_front/API/Media/media_read_response_dto.dart';

import 'enum/media_visibility.dart';

class Media {
  String eventHash;
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

    return other is Media && other.eventHash == eventHash;
  }

  @override
  int get hashCode => eventHash.hashCode;

  Media({
    required this.eventHash,
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
      eventHash: dto.hash,
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
