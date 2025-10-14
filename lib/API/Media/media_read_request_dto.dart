class MediaReadRequestDto {
  String parentHash;
  int? pageNumber;
  int? pageSize;

  MediaReadRequestDto({
    required this.parentHash,
    this.pageNumber,
    this.pageSize
  });

  Map<String, dynamic> toJson() {
    return {
      'parentHash': parentHash,
      'pageNumber': pageNumber,
      'pageSize': pageSize,
    };
  }
}
