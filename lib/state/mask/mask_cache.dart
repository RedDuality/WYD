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
      _masks.removeWhere((m) => m.id == mask.id); // sets keep the old version
      _masks.add(mask);
      notifyListeners();
    }
  }

  Future<void> _synchWithStorage(DateTimeRange updatedRange) async {
    if (!_rangeInCache.overlapsWith(updatedRange)) return;

    final overlap = _rangeInCache.getOverlap(updatedRange);
    if (overlap == null) return;

    var masks = await _storage.getMasksInRange(overlap);

    if (masks.isNotEmpty) {
      _masks.addAll(masks);
      notifyListeners();
    }
  }

  Future<void> loadMasksForRange(DateTimeRange<DateTime> newRange) async {
    if (newRange == _rangeInCache) return;

    _removeOutOfRangeMasks(newRange);

    await _addInRangeMasks(newRange);
  }

  void _removeOutOfRangeMasks(DateTimeRange range) {
    final masksToBeRemoved =
        allMasks.where((m) => (m.endTime.isBefore(range.start) || m.startTime.isAfter(range.end))).toList();

    if (masksToBeRemoved.isNotEmpty) {
      allMasks.removeAll(masksToBeRemoved);
    }
  }

  Future<void> _addInRangeMasks(DateTimeRange range) async {
    final addedIntervals = _rangeInCache.getAddedIntervals(range);

    List<Mask> masksToBeAdded = [];
    for (final interval in addedIntervals) {
      var masksAlreadyInStorage = await MaskStorageService.retrieveMasksInTimeRange(interval);
      masksToBeAdded.addAll(masksAlreadyInStorage);
    }

    allMasks.addAll(masksToBeAdded);

    _rangeInCache = range;
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
