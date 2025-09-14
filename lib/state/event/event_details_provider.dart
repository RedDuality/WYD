import 'package:flutter/material.dart';
import 'package:wyd_front/model/event_details.dart';
import 'package:wyd_front/model/media.dart';

class EventDetailsProvider extends ChangeNotifier {
  static final EventDetailsProvider _instance = EventDetailsProvider._internal();

  factory EventDetailsProvider() {
    return _instance;
  }

  EventDetailsProvider._internal();

  final Map<String, EventDetails> _eventDetails = {};

  EventDetails? get(String eventHash) => _eventDetails[eventHash];

  void create(String eventHash, EventDetails details) {
    _eventDetails[eventHash] != null ? throw "details alredy exists" : _eventDetails[eventHash] = details;
    notifyListeners();
  }

  void update(String eventHash, EventDetails details) {
    if (_eventDetails[eventHash] == null || _eventDetails[eventHash]!.updatedAt != details.updatedAt) {
      _eventDetails[eventHash] = details;
      notifyListeners();
    }
  }

  void addMedia(String eventHash, Set<Media> media, {DateTime? validUntil}) {
    if (_eventDetails[eventHash]!.media.isEmpty) {
      _eventDetails[eventHash]!.validUntil = validUntil!;
    }
    _eventDetails[eventHash]!.media.addAll(media);
    notifyListeners();
  }

  void addTotalMedia(String eventHash, int totalMedia) {
    _eventDetails[eventHash]!.totalImages += totalMedia;
    invalidateMediaCache(eventHash);
    notifyListeners();
  }

  void invalidateMediaCache(String eventHash) {
    _eventDetails[eventHash]!.media = {};
    _eventDetails[eventHash]!.validUntil = null;
  }

  void remove(String hash) {
    _eventDetails.remove(hash);
  }
}
