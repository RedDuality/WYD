import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/enum/profile_type.dart';
import 'package:wyd_front/model/enum/role.dart';
import 'package:wyd_front/model/test_event.dart';
import 'package:wyd_front/model/user.dart';
import 'package:wyd_front/service/user_service.dart';
import 'package:wyd_front/state/private_provider.dart';
import 'package:wyd_front/state/shared_provider.dart';

class UserProvider extends ChangeNotifier {
  late User _user;

  User? get user => _user;

  // Inject dependencies for PrivateProvider and SharedProvider
  final PrivateProvider privateProvider;
  final SharedProvider sharedProvider;

  UserProvider({required this.privateProvider, required this.sharedProvider});

  void setUser(User user) {
    _user = user;
    notifyListeners();

    List<TestEvent> events = [];
    UserService().listEvents().then((response) {
      if (response.statusCode == 200) {
        events = jsonDecode(response.body)
            .map((event) => TestEvent.fromJson(event as Map<String, dynamic>))
            .toList();
      }
    }).catchError((error) {
      debugPrint(error.toString());
    });

    int mainProfileId = user.profiles
        .firstWhere(
            (p) => p.type == ProfileType.personal && p.role == Role.owner)
        .id;

    List<TestEvent> sharedEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            true)
        .toList();
    List<TestEvent> privateEvents = events
        .where((ev) =>
            ev.sharedWith
                .firstWhere((s) => s.profileId == mainProfileId)
                .confirmed ==
            true)
        .toList();

    privateProvider.addEvents(privateEvents);
    sharedProvider.addEvents(sharedEvents);
  }
}
