import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';

// private functions are called internally, so could eventually need to notify listeners.
// public ones are called from external components(MaskController), which means the responsability of notifying is not handled by this component
class MaskCache extends ChangeNotifier {
  final MaskStorage _storage = MaskStorage();

  late final StreamSubscription<(Mask mask, bool deleted)> _updatesChannel;
  late final StreamSubscription<void> _clearAllChannel;

  final Set<Mask> _masks = {};

  MaskCache() {
    _updatesChannel = _storage.updatesChannel.listen((update) {
      _set(update.$1);
    });
    _clearAllChannel = _storage.clearChannel.listen((_) {
      clearAll();
    });
  }

  Set<Mask> get allMasks => _masks;

  void _set(Mask mask) {
    _masks.add(mask);
    notifyListeners();
  }

  void clearAll() {
    _masks.clear();
  }

  @override
  void dispose() {
    _clearAllChannel.cancel();
    _updatesChannel.cancel();
    super.dispose();
  }
}
