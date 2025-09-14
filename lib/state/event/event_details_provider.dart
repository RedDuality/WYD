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

  void set(String eventHash, EventDetails details) {
    _eventDetails[eventHash] = details;

    notifyListeners();
  }

  void addMedia(String eventHash, Set<Media> media, {DateTime? validUntil}) {
    var details = _eventDetails[eventHash]!;
    if (details.media.isEmpty) {
      details.validUntil = validUntil!;
    }
    details.media.addAll(media);
    details.totalImages += media.length;
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
