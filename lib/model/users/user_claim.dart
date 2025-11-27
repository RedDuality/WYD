class UserClaim {
  final String profileId;
  final String claim;

  UserClaim({
    required this.profileId,
    required this.claim,
  });

  factory UserClaim.fromJson(String profileId, String claim) {
    return UserClaim(
      profileId: profileId,
      claim: claim,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileId': profileId,
      'claim': claim,
    };
  }

  /// --- DB helpers ---
  Map<String, dynamic> toDbMap() {
    return {
      'profileId': profileId,
      'claim': claim,
    };
  }

  factory UserClaim.fromDbMap(Map<String, dynamic> map) {
    return UserClaim(
      profileId: map['profileId'] as String,
      claim: map['claim'] as String,
    );
  }
}
