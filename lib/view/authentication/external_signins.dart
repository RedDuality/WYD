import 'package:flutter/material.dart';
import 'package:wyd_front/service/util/authentication/google_sing_in_service.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';
import 'package:wyd_front/service/util/config/config_service.dart';
import 'package:wyd_front/view/authentication/google/google_signin_button.dart';

class ExternalSignins extends StatelessWidget {
  const ExternalSignins({super.key});

  @override
  Widget build(BuildContext context) {
    final supportedAuthPlatforms = ConfigService().supportedAuthPlatforms;

    return Column(
      children: [
        if (supportedAuthPlatforms.contains(SignInPlatform.google) && GoogleSignInService.isGoogleSignInInitialized)
          GoogleSigninButton(),
        // Divider
        if (supportedAuthPlatforms.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxWidth: 435),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              child: Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
