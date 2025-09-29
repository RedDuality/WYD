
class ShareEventRequestDto {
  String communityId;
  String groupId;

  ShareEventRequestDto({
    required this.communityId,
    required this.groupId,
  });


  // for share_page's set.contains method
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareEventRequestDto &&
        groupId == other.groupId;
  }

  @override
  int get hashCode => communityId.hashCode ^ groupId.hashCode;


  Map<String, dynamic> toJson() {
    return {
      'communityId': communityId,
      'groupId': groupId,
    };
  }
}
