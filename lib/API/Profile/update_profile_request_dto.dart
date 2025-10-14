



class UpdateProfileRequestDto {
  String profileHash;
  String? tag;
  String? name;
  int? color;

  UpdateProfileRequestDto({
    required this.profileHash,
    this.tag,
    this.name,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileHash,
      'tag': tag,
      'name': name,
      'color': color,
    };
  }
}