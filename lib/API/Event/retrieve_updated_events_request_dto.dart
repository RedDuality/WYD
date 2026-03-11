class RetrieveUpdatedEventsRequestDto {
  Set<String> profileIds;
  DateTime updatedAfterTime;

  RetrieveUpdatedEventsRequestDto({
    required this.profileIds,
    required this.updatedAfterTime,
  });


  Map<String, dynamic> toJson() {
    return {
      'profileIds': profileIds.toList(),
      'updatedAfterTime': updatedAfterTime.toUtc().toIso8601String(),
    };
  }
}
