// lib/services/config_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

import '/firebase_options_dev.dart' as dev;
import '/firebase_options_prod.dart' as prod;

import 'signin_web_config_helper_stub.dart' if (dart.library.js_util) 'signin_web_config_helper_web.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  factory ConfigService() => _instance;
  ConfigService._internal();

  late String backUrl;
  late String siteUrl;

  List<SignInPlatform> supportedAuthPlatforms = [SignInPlatform.google];
  late String googleClientId;

  Future<void> initialize() async {
    const env = String.fromEnvironment('ENV', defaultValue: 'dev');
    await dotenv.load(fileName: '.env.$env');

    final firebaseOptions =
        env == 'prod' ? prod.DefaultFirebaseOptions.currentPlatform : dev.DefaultFirebaseOptions.currentPlatform;

    await Firebase.initializeApp(options: firebaseOptions);

    loadFromEnv();
  }

  void loadFromEnv() {
    backUrl = dotenv.env['BACK_URL']!;
    siteUrl = dotenv.env['SITE_URL']!;

    final platformsString = dotenv.env['SUPPORTED_AUTH_PLATFORMS'] ?? '';
    supportedAuthPlatforms = platformsString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((name) => SignInPlatform.values.firstWhere(
              (e) => e.name == name,
              orElse: () => throw Exception('Unsupported platform: $name'),
            ))
        .toList();

    _applyWebConfig(dotenv.env);
  }

/*
  void loadFromRemote(Map<String, dynamic> remoteConfig) {
    backUrl = remoteConfig['backUrl'] ?? backUrl;
    siteUrl = remoteConfig['siteUrl'] ?? siteUrl;

    final platformsString = remoteConfig['SUPPORTED_AUTH_PLATFORMS'] ?? '';
    supportedAuthPlatforms = platformsString
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .map((name) => SignInPlatform.values.firstWhere(
              (e) => e.name == name,
              orElse: () => throw Exception('Unsupported platform: $name'),
            ))
        .toList();

    _applyWebConfig(remoteConfig);
  }
*/
  void _applyWebConfig(Map<String, dynamic> variables) {
    for (final platform in supportedAuthPlatforms) {
      switch (platform) {
        case SignInPlatform.google:
          googleClientId = variables['GOOGLE_CLIENT_ID']!;
          if (kIsWeb) {
            applyWebConfigImpl('google-signin-client_id', supportedAuthPlatforms, googleClientId);
          }
        case SignInPlatform.email:
          break;
      }
    }
  }
}
