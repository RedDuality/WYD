import 'package:wyd_front/API/Media/media_read_response_dto.dart';

import 'enum/media_visibility.dart';

class Media {
  String hash;
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

    return other is Media && other.hash == hash;
  }

  @override
  int get hashCode => hash.hashCode;

  Media({
    required this.hash,
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
      hash: dto.hash,
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
