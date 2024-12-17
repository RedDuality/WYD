import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signalr_netcore/ihub_protocol.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:wyd_front/service/util/interceptor/auth_interceptor.dart';

class RealTimeProvider with ChangeNotifier {
  // Make the singleton instance private and static
  static final RealTimeProvider _instance = RealTimeProvider._internal();

  factory RealTimeProvider({BuildContext? context}) {
    return _instance;
  }

  final String realTimeUpdateUrl = '${dotenv.env['BACK_URL']}';
  static late final HubConnection _hubConnection;

  // Private constructor
  RealTimeProvider._internal();

  initialize() async {
    String? header = await AuthInterceptor().getAuthHeader();
    var defaultHeaders = MessageHeaders();
    defaultHeaders.setHeaderValue(HttpHeaders.authorizationHeader, header!);

    var httpConnectionOptions = HttpConnectionOptions(headers: defaultHeaders);

    _hubConnection = HubConnectionBuilder()
        .withUrl(realTimeUpdateUrl, options: httpConnectionOptions)
        .build();

    debugPrint('initialized signalr connection');

    _hubConnection.on(
        'ReceiveUpdate', (arguments) => _handleReceiveUpdate(arguments));

    _startConnection();
  }

  Future<void> _startConnection() async {
    //await _hubConnection.start();
    notifyListeners();
  }

  void _handleReceiveUpdate(List<Object?>? args) {
    if (args != null && args.isNotEmpty) {
      final message = args[0] as String;
      debugPrint('Received message: $message');
      // You can add more logic here to handle the received message
    }
  }

  @override
  void dispose() {
    _hubConnection.stop();
    super.dispose();
  }

  void stopConnection(String userHash) async {
    await _hubConnection.invoke("RemoveFromGroup", args: <Object>[userHash]);
    await _hubConnection.stop();
    debugPrint("Connection stopped and left group $userHash");
  }
}
