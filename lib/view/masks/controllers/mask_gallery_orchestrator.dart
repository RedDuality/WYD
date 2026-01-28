import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/controllers/mask_range_controller.dart';

class MaskGalleryOrchestrator with ChangeNotifier {
  final MaskController _maskController;
  final MaskRangeController _rangeController;
  final String _profileId;

  bool _isLoading = false;

  MaskGalleryOrchestrator({
    required MaskController maskController,
    required MaskRangeController rangeController,
    required String profileId
  })  : _maskController = maskController,
        _rangeController = rangeController,
        _profileId = profileId;

  void initialize() {
    _rangeController.addListener(_handleRangeUpdate);

    _onRangeChange(logger: "InitialLoad");
  }

  void _handleRangeUpdate() {
    _onRangeChange(logger: "fromRangeUpdate");
  }

  MaskController get maskCntrl => _maskController;
  MaskRangeController get rangeCntrl => _rangeController;

  Future<void> _onRangeChange({String logger = ""}) async {
    debugPrint("retrieveMasks, $logger");

    if (_isLoading) return;

    _isLoading = true;

    unawaited(_retrieveMasks());
  }

  Future<void> _retrieveMasks() async {
    final range = _rangeController.currentRange;

    final masks = await MaskService.retrieveProfileMasks(_profileId, range);

    _isLoading = false;
    _maskController.updateWithMasks(masks);
  }

  bool get isLoading => _isLoading;

  @override
  void dispose() {
    _rangeController.removeListener(_handleRangeUpdate);
    _rangeController.dispose();
    super.dispose();
  }
}
