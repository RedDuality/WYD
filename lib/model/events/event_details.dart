import 'package:wyd_front/model/media/media.dart';

class EventDetails {
  String detailsId = "";
  String description = "";
  int totalImages = 0;

  String? recurrenceRule;

  DateTime? updatedAt;
  DateTime? validUntil;

  Set<Media> media = {};

  EventDetails({
    required this.detailsId,
    required this.description,
    required this.totalImages,
    this.updatedAt,
    this.recurrenceRule,
  });

  // Factory constructor to create a Profile from JSON
  factory EventDetails.fromJson(Map<String, dynamic> json) {
    return EventDetails(
      detailsId: json['hash'] as String,
      description: json['description'] as String? ?? '',
      totalImages: json['totalImages'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      recurrenceRule: json['recurrenceRule'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hash': detailsId,
      'description': description,
      'totalImages': totalImages,
      'recurrenceRule': recurrenceRule,
    };
  }
}
