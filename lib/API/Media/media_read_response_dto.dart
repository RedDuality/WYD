import 'package:wyd_front/model/enum/media_visibility.dart';

class MediaReadResponseDto {
  String hash;
  //String? parentId;
  
  String? extension;
  String? name;
  DateTime? creationDate;
  //MediaType? type;
  
  MediaVisibility? visibility;
  String? url;
  DateTime? validUntil;
  String? error;

  MediaReadResponseDto({
    required this.hash,
    //this.parentId,
    this.extension,
    this.name,
    this.creationDate,

    //this.type,
    this.visibility,
    this.url,
    this.validUntil,
    this.error,
  });

  factory MediaReadResponseDto.fromJson(Map<String, dynamic> json) {
    return MediaReadResponseDto(
      hash: json['id'] as String,
      //parentId: json['parentId'] as String?,
      extension: json['extension'] as String?,
      name: json['name'] as String?,
      creationDate: json['creationDate'] != null ? DateTime.parse(json['creationDate'] as String).toUtc() : null,
      //type: (json['type'] is String) ? MediaType.values.byName(json['type'] as String) : null,
      visibility: MediaVisibility.values[json['visibility'] ?? 0],
      url: json['url'] as String?,
      validUntil: json['validUntil'] != null ? DateTime.parse(json['validUntil'] as String).toUtc() : null,
      error: json['error'] as String?,
    );
  }
}
