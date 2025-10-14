class MediaInfo {
  String id;
  DateTime creationDate;
  String mimetype;

  MediaInfo({
    required this.id,
    required this.creationDate,
    required this.mimetype,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': creationDate.toIso8601String(),
      'mimetype': mimetype,
    };
  }
}

class MediaUploadRequestDto {
  String parentHash;
  List<MediaInfo> media;

  MediaUploadRequestDto({
    required this.parentHash,
    required this.media,
  });

  Map<String, dynamic> toJson() {
    return {
      'parentHash': parentHash,
      'media': media.map((image) => image.toJson()).toList(),
    };
  }
}
