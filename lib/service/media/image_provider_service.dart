import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/image_size.dart';
import 'package:wyd_front/service/media/logo_service.dart';

class ImageProviderService {
  static ImageProvider? getProfileImage(String profileHash, String blobHash, {ImageSize size = ImageSize.big}) {
    return LogoService.wydLogoImageProvider(size);
  }

  static ImageProvider getImageProvider({String? imageUrl, ImageSize size = ImageSize.big}) {
    return LogoService.wydLogoImageProvider(size);
  }
}
