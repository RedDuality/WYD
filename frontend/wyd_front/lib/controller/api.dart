import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Api{

  String functionUrl = 'https://wydcalendarapi.azurewebsites.net/api/';
  //String functionUrl = 'http://localhost:7071/api/';

  void sendJson(String jsonString){
    // Define the Azure Function URL
    String url = '${functionUrl}SaveEvent';

    // Make a POST request to the Azure Function
    http.post(Uri.parse(url), body: jsonString).then((response) {
      // Print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }).catchError((error) {
      // Handle errors
      debugPrint('Error: $error');
    });
  }

  void createUser(){
    String url = '${functionUrl}CreateUser';

    // Make a POST request to the Azure Function
    http.get(Uri.parse(url),).then((response) {
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
    final response = await http.post(Uri.parse(url), body: jsonString);
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

    final response = await http.get(Uri.parse(url),headers: {'Access-Control-Allow-Origin': '*'});
    if(response.statusCode == 200) {
      return response.body;
    }else {
      throw Exception('Failed to load events'); 
    }

  }


  void deleteEvent(){

  }

}


/*
  void toggleFavorite() {
    // Define the JSON object to pass to the Azure Function
    Map<String, dynamic> jsonObject = {
      'name': 'John',
      'age': 30,
    };

    // Convert the JSON object to a string
    String jsonString = jsonEncode(jsonObject);

    // Define the Azure Function URL
    String functionUrl = 'https://wyd-function-prova1.azurewebsites.net/api/SaveExam';

    // Make a POST request to the Azure Function
    http.post(Uri.parse(functionUrl), body: jsonString).then((response) {
      // Print the response
      debugPrint('Response status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
    }).catchError((error) {
      // Handle errors
      debugPrint('Error: $error');
    });
  }
*/