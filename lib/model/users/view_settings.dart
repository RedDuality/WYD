class ViewSettings {
  final String viewerId;
  final String viewedId; 
  final bool viewConfirmed;
  final bool viewShared;

  ViewSettings({
    required this.viewerId,
    required this.viewedId,
    required this.viewConfirmed,
    required this.viewShared,
  });

  factory ViewSettings.fromJson(String profileId, Map<String, dynamic> json) {
    return ViewSettings(
      viewerId: profileId,
      viewedId: json['profileId'] as String,
      viewConfirmed: json['viewConfirmed'] as bool,
      viewShared: json['viewShared'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': viewedId,
      'viewConfirmed': viewConfirmed,
      'viewShared': viewShared,
    };
  }

  /// --- DB helpers ---
  Map<String, dynamic> toDbMap() {
    return {
      'viewerId': viewerId,
      'viewedId': viewedId,
      'viewConfirmed': viewConfirmed ? 1 : 0,
      'viewShared': viewShared ? 1 : 0,
    };
  }

  factory ViewSettings.fromDbMap(Map<String, dynamic> map) {
    return ViewSettings(
      viewerId: map['viewerId'] as String,
      viewedId: map['viewedId'] as String,
      viewConfirmed: (map['viewConfirmed'] as int) == 1,
      viewShared: (map['viewShared'] as int) == 1,
    );
  }
}
