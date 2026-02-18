import 'package:flutter/material.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget getWebGoogleButton() {
  return LayoutBuilder(builder: (context, constraints) {
    final double calculatedWidth = constraints.maxWidth.clamp(200, 399);
    return SizedBox(
      height: 40,
      width: calculatedWidth,
      child: web.renderButton(
        configuration: web.GSIButtonConfiguration(
          type: web.GSIButtonType.standard,
          theme: web.GSIButtonTheme.outline,
          size: web.GSIButtonSize.large,
          text: web.GSIButtonText.signinWith,
          shape: web.GSIButtonShape.rectangular,
          logoAlignment: web.GSIButtonLogoAlignment.left,
          minimumWidth: calculatedWidth,
        ),
      ),
    );
  });
}