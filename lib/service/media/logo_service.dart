import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/image_size.dart';
import 'package:wyd_front/service/util/authentication/sign_in_platform.dart';

class LogoService {
  static ImageProvider importProviderLogo(SignInPlatform provider, ImageSize size) {
    switch (provider) {
      case SignInPlatform.google:
        return _googleCalendarImageProvider(size);
      case SignInPlatform.email:
        return wydLogoImageProvider(size);
    }
  }

  static ImageProvider wydLogoImageProvider(ImageSize size) {
    String path;
    switch (size) {
      case ImageSize.mini:
        path = 'assets/images/logoimage_mini.png';
        break;
      case ImageSize.big:
      default:
        path = 'assets/images/logoimage.png';
        break;
    }

    return AssetImage(path);
  }

  static ImageProvider googleImageProvider(ImageSize size) {
    String path;
    switch (size) {
      case ImageSize.mini:
        path = 'assets/images/google_logo.png';
        break;
      case ImageSize.big:
      default:
        path = 'assets/images/google_logo.png';
        break;
    }

    return AssetImage(path);
  }

  static ImageProvider _googleCalendarImageProvider(ImageSize size) {
    String path;
    switch (size) {
      case ImageSize.mini:
        path = 'assets/images/google_calendar_mini.png';
        break;
      case ImageSize.midi:
        path = 'assets/images/google_calendar_midi.png';
        break;
      case ImageSize.big:
        path = 'assets/images/google_calendar.png';
        break;
    }

    return AssetImage(path);
  }
}
