import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class ExternalImports {
  final String importedEmail;
  final SignInPlatform importType;

  ExternalImports({
    required this.importedEmail,
    required this.importType,
  });

  factory ExternalImports.fromJson(Map<String, dynamic> json) {
    return ExternalImports(
      importedEmail: json['importedAccount'] as String,
      importType: SignInPlatform.fromString(json['importType'] as String),
    );
  }

  /// --- DB helpers ---
  Map<String, dynamic> toDbMap() {
    return {
      'user': importedEmail,
      'type': importType.toString(),
    };
  }

  factory ExternalImports.fromDbMap(Map<String, dynamic> map) {
    return ExternalImports(
      importedEmail: map['user'] as String,
      importType: SignInPlatform.fromString(map['type'] as String),
    );
  }
}
