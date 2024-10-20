import 'package:flutter/material.dart';

class UriProvider extends ChangeNotifier {

  var _uri = "";

  String get uri => _uri;
  
  void setUri(String uri){
    _uri = uri;
  }
}