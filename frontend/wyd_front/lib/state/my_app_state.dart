import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:wyd_front/model/events.dart';



class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  var privateEvents = Events();
  var sharedEvents = Events();

  var authToken = "random_token";
  
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}
