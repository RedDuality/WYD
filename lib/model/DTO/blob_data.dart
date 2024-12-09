import 'dart:convert';
import 'dart:typed_data';

class BlobData {
  Uint8List data;
  String mimeType;

  BlobData({
    required this.data,
    required this.mimeType,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': base64Encode(data),
      'mimeType': mimeType,
    };
  }

  factory BlobData.fromJson(Map<String, dynamic> json) {
    return BlobData(
      data: base64Decode(json['data']),
      mimeType: json['extension'],
    );
  }
}
