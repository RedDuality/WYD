


class UserDto {
  int id = 0;
  String userName = "";
  String tag = "";
  int mainProfileId = 0;

  UserDto({
    this.id = 0,
    this.userName = "",
    this.tag = "",
    this.mainProfileId = 0
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'id': int? id,
        'userName': String? username,
        'tag': String? tag,
        'mainProfileId': int? mainProfileId,
      } =>
        UserDto(
          id: id ?? 0,
          userName: username ?? "",
          tag: tag ?? "",
          mainProfileId: mainProfileId ?? 0,
        ),
      _ => throw const FormatException('Failed to decode UserDto')
    };
  }


    Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'tag': tag,
      'mainProfileId': mainProfileId,
    };
  }
}
