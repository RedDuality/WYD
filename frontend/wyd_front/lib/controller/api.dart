import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class Api{

  String functionUrl = 'https://wydcalendarapi.azurewebsites.net/api/';

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

  void listEvents(){
    String url = '${functionUrl}ListEvents/1';

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