import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/model/util/date_time_interval.dart';
import 'package:wyd_front/service/mask/mask_storage_service.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';

// private functions are called internally, so could eventually need to notify listeners.
// public ones are called from external components(MaskController), which means the responsability of notifying is not handled by this component
class MaskCache extends ChangeNotifier {
  final MaskStorage _storage = MaskStorage();

  late final StreamSubscription<DateTimeRange> _rangesChannel;
  late final StreamSubscription<(Mask mask, bool deleted)> _updatesChannel;
  late final StreamSubscription<void> _clearAllChannel;

  DateTimeRange _rangeInCache = DateTimeRange(
    start: DateTime.fromMicrosecondsSinceEpoch(0),
    end: DateTime.fromMillisecondsSinceEpoch(1),
  );

  final Set<Mask> _masks = {};

  MaskCache() {
    _rangesChannel = _storage.rangesChannel.listen((updatedRange) {
      _synchWithStorage(updatedRange);
    });

    _updatesChannel = _storage.updatesChannel.listen((update) {
      if (update.$2) {
        _delete(update.$1);
      } else {
        _addOrUpdate(update.$1);
      }
    });

    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Set<Mask> get allMasks => _masks;
  Mask findById(String maskId) => _masks.where((m) => m.id == maskId).first; 

  void _addOrUpdate(Mask mask) {
    final inTimeRange = _rangeInCache.overlapsWith(DateTimeRange(start: mask.startTime, end: mask.endTime));

    if (inTimeRange) {
      Mask? inMemoryMask = _masks.where((m) => m.id == mask.id).firstOrNull;
      if (inMemoryMask != null) {
        _masks.remove(inMemoryMask);
      }

      _masks.add(mask);
      notifyListeners();
    }
  }

  Future<void> _synchWithStorage(DateTimeRange updatedRange) async {
    if (!_rangeInCache.overlapsWith(updatedRange)) return;

    final overlap = _rangeInCache.getOverlap(updatedRange);
    if (overlap == null) return;

    var events = await _storage.getMasksInRange(overlap);

    if (events.isNotEmpty) {
      _masks.addAll(events);
      notifyListeners();
    }
  }

  Future<void> loadMasksForRange(DateTimeRange<DateTime> newRange) async {
    if (newRange == _rangeInCache) {
      //no need to load from the server
      debugPrint("rangeSkip");
      //make it load from cache
      WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
      return;
    }

    final masksToBeRemoved =
        allMasks.where((m) => (m.endTime.isBefore(newRange.start) || m.startTime.isAfter(newRange.end))).toList();

    if (masksToBeRemoved.isNotEmpty) {
      allMasks.removeAll(masksToBeRemoved);
    }

    unawaited(_retrieveMaskFromStorage(newRange));
  }

  Future<void> _retrieveMaskFromStorage(DateTimeRange<DateTime> newRange) async {
    final addedIntervals = _rangeInCache.getAddedIntervals(newRange);

    _rangeInCache = newRange;

    List<Mask> masksToBeAdded = [];
    for (final interval in addedIntervals) {
      var masksAlreadyInStorage = await MaskStorageService.retrieveMasksInTimeRange(interval);
      masksToBeAdded.addAll(masksAlreadyInStorage);
    }

    allMasks.addAll(masksToBeAdded);
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
    debugPrint("notifyListeners");
  }

  void _delete(Mask mask) {
    _masks.remove(mask);
    notifyListeners();
  }

  void clearAll() {
    _masks.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _rangesChannel.cancel();
    _updatesChannel.cancel();
    super.dispose();
  }
}
