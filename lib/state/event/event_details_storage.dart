import 'package:flutter/material.dart';
import 'package:wyd_front/model/events/event_details.dart';
import 'package:wyd_front/model/media/media.dart';

class EventDetailsStorage extends ChangeNotifier {
  
  static final EventDetailsStorage _instance = EventDetailsStorage._internal();
  factory EventDetailsStorage() => _instance;
  EventDetailsStorage._internal();

  final Map<String, EventDetails> _eventDetails = {};

  EventDetails? get(String eventId) => _eventDetails[eventId];

  void create(String eventId, EventDetails details) {
    _eventDetails[eventId] != null ? throw "details alredy exists" : _eventDetails[eventId] = details;
    notifyListeners();
  }

  void update(String eventId, EventDetails details) {
    if (_eventDetails[eventId] == null || _eventDetails[eventId]!.updatedAt != details.updatedAt) {
      _eventDetails[eventId] = details;
      notifyListeners();
    }
  }

  void addMedia(String eventId, Set<Media> media, {DateTime? validUntil}) {
    if (_eventDetails[eventId]!.media.isEmpty) {
      _eventDetails[eventId]!.validUntil = validUntil!;
    }
    _eventDetails[eventId]!.media.addAll(media);
    notifyListeners();
  }

  void addTotalMedia(String eventId, int totalMedia) {
    _eventDetails[eventId]!.totalImages += totalMedia;
    invalidateMediaCache(eventId);
    notifyListeners();
  }

  void invalidateMediaCache(String eventId) {
    _eventDetails[eventId]!.media = {};
    _eventDetails[eventId]!.validUntil = null; // this makes the widget retrieve all the old images
  }

  void remove(String hash) {
    _eventDetails.remove(hash);
  }
}
