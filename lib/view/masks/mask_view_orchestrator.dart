import 'package:flutter/material.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/mask_range_controller.dart';

class MaskViewOrchestrator with ChangeNotifier {
  final MaskCache _maskCache;
  final MaskController _maskController;
  final MaskRangeController _rangeController;

  bool _isLoading = false;

  MaskViewOrchestrator({
    required MaskCache maskCache,
    required MaskController maskController,
    required MaskRangeController rangeController,
  })  : _maskCache = maskCache,
        _maskController = maskController,
        _rangeController = rangeController;

  void initialize() {
    _maskCache.addListener(_updateMaskController);

    _rangeController.addListener(_handleRangeUpdate);

    _rangeController.attach();

    _updateMaskController();

    _onRangeChange(logger: "InitialLoad");
  }

  void _handleRangeUpdate() {
    _onRangeChange(logger: "fromRangeUpdate");
  }

  MaskController get maskCntrl => _maskController;
  MaskRangeController get rangeCntrl => _rangeController;

  void _onRangeChange({String logger = ""}) {
    debugPrint("retrieveMasks, $logger");

    if (_isLoading) return;

    _isLoading = true;

    _maskCache.loadMasksForRange(_rangeController.focusedRange).then((_) {
      _isLoading = false;
      notifyListeners();
    });
  }

  void _updateMaskController() {
    _maskController.updateWithMasks();
    notifyListeners();
  }

  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _rangeController.removeListener(_handleRangeUpdate);
    _maskCache.removeListener(_updateMaskController);
    _rangeController.dispose();
    super.dispose();
  }
}
