import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/util/request_interceptor.dart';

class ImageApi {
  String? blobUrl = '${dotenv.env['BLOB_URL']}';

  final InterceptedClient client;

  ImageApi()
      : client = InterceptedClient.build(interceptors: [
          RequestInterceptor(),
        ]);

  Future<Response> retrieveImage(String containerName, String blobName) async {
    final url = '$blobUrl${containerName.toLowerCase()}/${blobName.toLowerCase()}';
    return client.get(Uri.parse(url));
  }
}
