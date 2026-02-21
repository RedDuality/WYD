import 'package:wyd_front/API/User/account_dto.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class Account {
  String mail = "";
  SignInPlatform? platform;

  Account({
    required this.mail,
    required this.platform,
  });

  Account.fromDto(AccountDto dto) {
    mail = dto.mail;
    platform = _mapStringToPlatform(dto.signInType);
  }

  static SignInPlatform? _mapStringToPlatform(String type) {
    switch (type.toLowerCase()) {
      case 'google':
        return SignInPlatform.google;
      case 'email':
      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'mail': mail,
      'platform': platform.toString(),
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      mail: json['mail'] as String,
      platform: _mapStringToPlatform(json['platform']),
    );
  }
}
