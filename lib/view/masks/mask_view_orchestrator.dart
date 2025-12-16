import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/mask_range_controller.dart';

class MaskViewOrchestrator with ChangeNotifier {
  final MaskCache _maskCache;
  final MaskController _maskController;

  final MaskRangeController _rangeController;

  bool _isLoading = true;

  MaskViewOrchestrator({
    required MaskCache maskCache,
    required MaskController maskController,
    required MaskRangeController rangeController,
  })  : _maskCache = maskCache,
        _maskController = maskController,
        _rangeController = rangeController;


  void initialize() {
    _maskCache.addListener(notifyListeners);

    _rangeController.addListener(() {
      _onRangeChange(logger: "fromRangeUpdate");
    });

    _onRangeChange(logger: "InitialLoad");
  }

  MaskController get maskCntrl => _maskController;
  MaskRangeController get rangeCntrl => _rangeController;


  Future<void> _onRangeChange({String logger = ""}) async {
    _isLoading = true;

    debugPrint("loadMasks, $logger");

    await _maskCache.loadMasksForRange(_rangeController.focusedRange);

    // Update controller with loaded masks
    _maskController.updateWithMasks(_maskCache.allMasks);

    _isLoading = false;

    notifyListeners();
  }

  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _rangeController.removeListener(_onRangeChange);
    _maskCache.removeListener(notifyListeners);
    _rangeController.dispose();
    super.dispose();
  }
}
