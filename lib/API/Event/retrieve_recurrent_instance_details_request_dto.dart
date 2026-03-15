class RetrieveRecurrentInstanceDetailsRequestDto {
  String masterEventId;
  String recurrencyInstanceId;


  RetrieveRecurrentInstanceDetailsRequestDto({
    required this.masterEventId,
    required this.recurrencyInstanceId,
  });


  Map<String, dynamic> toJson() {
    return {
      'masterEventId': masterEventId,
      'recurrencyInstanceId': recurrencyInstanceId,
    };
  }
}
