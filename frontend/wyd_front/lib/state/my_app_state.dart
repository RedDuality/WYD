import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';
import 'package:wyd_front/model/user.dart';



class MyAppState extends ChangeNotifier {


  late User user ;

  var authToken = "random_token";
  
  void setUser(User user){
    this.user = user;
  }


  var current = WordPair.random();
  
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
