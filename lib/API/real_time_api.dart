import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:wyd_front/service/util/auth_interceptor.dart';

class RealTimeUpdatesAPI {
  String? functionUrl = '${dotenv.env['BACK_URL']}RTUpdates/';
  final InterceptedClient client;
  HubConnection? _hubConnection;

  RealTimeUpdatesAPI()
      : client = InterceptedClient.build(interceptors: [
          AuthInterceptor(),
        ]);

  Future<Response> ping() async {
    String url = '${functionUrl}Ping';

    return client.get(
      Uri.parse(url),
    );
  }

  Future<Response> addProfileToGroup(String userId, String profileId) async {
    final url = Uri.parse(
        '${functionUrl}addToProfileGroup?userId=$userId&profileId=$profileId');
    return client.post(url);
  }
}
