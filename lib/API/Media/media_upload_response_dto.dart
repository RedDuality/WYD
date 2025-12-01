import 'package:wyd_front/model/enum/media_type.dart';
import 'package:wyd_front/model/enum/media_visibility.dart';

class MediaUploadResponseDto {
  final String tempId;
  final String? id;
  final String? name;
  final String? extension;
  final MediaVisibility? visibility;
  final MyMediaType? type;
  final String? url;

  final String? error;

  MediaUploadResponseDto({
    required this.tempId,
    this.id,
    this.name,
    this.extension,
    this.url,
    this.visibility,
    this.type,
    this.error,
  });

  factory MediaUploadResponseDto.fromJson(Map<String, dynamic> json) {
    return MediaUploadResponseDto(
      tempId: json['tempId'] as String,
      id: json['id'] as String?,
      name: json['name'] as String?,
      extension: json['extension'] as String?,
      type: (json['type'] is String) ? MyMediaType.values.byName(json['type'] as String) : null,
      visibility: MediaVisibility.values[json['visibility'] ?? 0],
      url: json['url'] as String?,
      error: json['error'] as String?,
    );
  }
}
