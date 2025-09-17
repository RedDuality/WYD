import 'package:flutter/material.dart';
import 'package:wyd_front/state/user/user_provider.dart';

class FcmManager {
  static final FcmManager _instance = FcmManager._internal();

  factory FcmManager({BuildContext? context}) {
    return _instance;
  }

  FcmManager._internal();

  Future<void> start() async {
    var user = UserProvider().user;
    if (user == null) throw "User is null";
  }
}
