class ShareEventRequestDto {
  final Set<ShareGroupIdentifierDto> sharedGroups;

  ShareEventRequestDto({
    required this.sharedGroups,
  });

  Map<String, dynamic> toJson() {
    return {
      'sharedGroups': sharedGroups.map((group) => group.toJson()).toList(),
    };
  }
}

class ShareGroupIdentifierDto {
  final String communityId;
  final String groupId;

  ShareGroupIdentifierDto({
    required this.communityId,
    required this.groupId,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ShareGroupIdentifierDto &&
        other.communityId == communityId &&
        other.groupId == groupId;
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