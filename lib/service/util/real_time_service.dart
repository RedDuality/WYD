import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/signalr_client.dart';

class RealTimeService {
  String? functionUrl = '${dotenv.env['BACK_URL']}';
  HubConnection? _hubConnection;

  void initialize() {
    _hubConnection =
        HubConnectionBuilder().withUrl("$functionUrl/negotiate").build();

    _hubConnection?.onclose((error) => print("Connection Closed"));
    _hubConnection?.on("ReceiveMessage", (message) {
      print("Message received: $message");
    });

    _hubConnection
        ?.start()
        .catchError((error) => print("Connection failed: $error"));

            // Subscribe to each profile's channel
    for (String profileId in userProvider.profileIds) {
      await addProfileToGroup(userProvider.userId, profileId);
    }
    
  }

  void dispose() {
    _hubConnection?.stop();
  }
}
