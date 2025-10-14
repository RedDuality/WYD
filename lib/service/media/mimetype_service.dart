import 'dart:typed_data';

class MimetypeService {
  List<String> getAllowedExtensions() {
    return [/*'pdf', 'mp4',*/ 'jpg', 'jpeg', 'png', 'gif'];
  }

  static String? getMimeType(Uint8List data) {
    // Dynamically try to determine the MIME type from image headers
    if (data.length >= 4) {
      if (data[0] == 0x89 &&
          data[1] == 0x50 &&
          data[2] == 0x4E &&
          data[3] == 0x47) {
        return "image/png";
      } else if (data[0] == 0xFF && data[1] == 0xD8 && data[2] == 0xFF) {
        return "image/jpeg";
      } else if (data[0] == 0x47 && data[1] == 0x49 && data[2] == 0x46) {
        return "image/gif";
      }
    }
    return null;
  }

  static String? getMimeTypeFromExtension(String extension) {

    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'pdf':
        return 'application/pdf';
      case 'mp4':
        return 'video/mp4';
      default:
        return null;
    }
  }
}
