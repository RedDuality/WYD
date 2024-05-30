import 'package:flutter/material.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:wyd_front/service/auth_interceptor.dart';


class Api{

  //String functionUrl = 'https://wydcalendarapi.azurewebsites.net/api/';
  String functionUrl = 'http://localhost:7071/';


  Client client = InterceptedClient.build(interceptors: [
      AuthInterceptor(),
  ]);

  void createUser(){
    String url = '${functionUrl}CreateUser';

    // Make a POST request to the Azure Function
    client.get(Uri.parse(url),).then((response) {
      // Print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }).catchError((error) {
      // Handle errors
      debugPrint('Error: $error');
    });

  }

  Future<String> createEvent(String jsonString) async {
    // Define the Azure Function URL
    String url = '${functionUrl}CreateEvent';

    // Make a POST request to the Azure Function
    final response = await client.post(Uri.parse(url), body: jsonString);
    if(response.statusCode == 200) {
      // Print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response.body;
    }else {
      throw Exception();
    }
  }

  Future<String> updateEvent(String jsonString) async {
    // Define the Azure Function URL
    String url = '${functionUrl}UpdateEvent';

    // Make a POST request to the Azure Function
    final response = await client.post(Uri.parse(url), body: jsonString);
    if(response.statusCode == 200) {
      // Print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      return response.body;
    }else {
      throw Exception();
    }
  }




  Future<String> listEvents()  async {
    String url = '${functionUrl}ListEvents/1';

    final response = await client.get(url.toUri());
    if(response.statusCode == 200) {
      return response.body;
    }else {
      throw Exception('Failed to load events'); 
    }

  }


  Future<bool> deleteEvent(String jsonString) async {
    String url = '${functionUrl}DeleteEvent';

    final response = await client.post(Uri.parse(url), body: jsonString);
    if(response.statusCode == 200) {

      return true;
    }else {
      throw Exception();
    }
  }

  Future<bool> Ping() async {
    String url = '${functionUrl}Ping';

    final response = await client.get(Uri.parse(url),);
    if(response.statusCode == 200) {

      return true;
    }else {
      throw Exception();
    }
  }
}