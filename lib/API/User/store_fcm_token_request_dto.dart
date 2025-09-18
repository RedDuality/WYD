class StoreFcmTokenRequestDto {
  String uuid;
  String platform;
  String fcmToken;


  StoreFcmTokenRequestDto({
    required this.uuid,
    required this.platform,
    required this.fcmToken,
  });


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'platform': platform,
      'fcmToken': fcmToken,
    };
  }
}
