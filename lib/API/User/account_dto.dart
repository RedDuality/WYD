class AccountDto {
  String mail = "";
  String signInType = "";
  

  AccountDto({
    required this.mail,
    required this.signInType,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      mail: json['mail'] as String,
      signInType: json['signInType'] as String,
    );
  }
}
