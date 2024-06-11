import 'package:flutter/material.dart';

class ErrorController{

  showErrorDialog(BuildContext context, String title, String content){
    return showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget> [
            TextButton(onPressed: () { Navigator.of(context).pop();}, 
            child: const Text('OK'))
          ]
        );
      }
    );
  }
}