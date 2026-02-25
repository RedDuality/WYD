class AccountDto {
  final String email;
  final String signInType;
  final String? importedBy;
  

  AccountDto({
    required this.email,
    required this.signInType,
    this.importedBy,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      email: json['email'] as String,
      signInType: json['signInType'] as String,
      importedBy: json['importedBy'] as String?,
    );
  }
}
