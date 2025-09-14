import 'package:wyd_front/model/media.dart';

class EventDetails {
  String hash = "";
  String? description = "";
  int totalImages = 0;
  DateTime? updatedAt;
  DateTime? validUntil;

  Set<Media> media = {};

  EventDetails({
    required this.hash,
    this.description,
    required this.totalImages,
    this.updatedAt,
  });

  // Factory constructor to create a Profile from JSON
  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      hash: json['hash'] as String,
      description: json['description'] as String?,
      totalImages: json['totalImages'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': hash,
      'description': description,
      'totalImages': totalImages,
    };
  }
}
