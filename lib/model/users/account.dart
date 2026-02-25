import 'package:wyd_front/API/User/account_dto.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class Account {
  String email = "";
  SignInPlatform platform;
  String? importedBy;

  Account({
    required this.email,
    required this.platform,
    this.importedBy,
  });

  factory Account.fromDto(AccountDto dto) {
    return Account(
      email: dto.email,
      platform: SignInPlatform.fromString(dto.signInType),
      importedBy: dto.importedBy,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mail': email,
      'platform': platform.toString(),
      'importedBy': importedBy,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      email: json['mail'] as String,
      platform: SignInPlatform.fromString(json['platform']),
      importedBy: json['importedBy'] as String?,
    );
  }
}
