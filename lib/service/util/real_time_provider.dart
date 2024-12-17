import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/update_type.dart';

class RealTimeProvider with ChangeNotifier {
  static final RealTimeProvider _instance = RealTimeProvider._internal();

  factory RealTimeProvider({BuildContext? context}) {
    return _instance;
  }
  // Private constructor
  RealTimeProvider._internal();

  bool firstread = true;

  initialize(String userHash) async {
    FirebaseFirestore.instance
        .collection(userHash)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .listen((snapshot) {
      if (firstread) {
        firstread = false;
      } else {
        handleUpdate(snapshot.docs);
      }
    });
  }

  void handleUpdate(var snapshot) {
    var type = snapshot['type'];
    switch (type) {
      case UpdateType.event:
        _handleEventUpdate(snapshot['id']);
        break;
      case UpdateType.confirm:
        //_handleConfirmUpdate(snapshot['id']);
        break;
      case UpdateType.profile:
        //_handleProfileUpdate(snapshot['id']);
        break;
      default:
    }
  }

  void _handleEventUpdate(var id) {
    if(int.parse(id).isNaN) {
      debugPrint("RTService, error in event id convertion");
      return;
    }
    int eventId  =  int.parse(id);
    
    
    
    
  }
}
