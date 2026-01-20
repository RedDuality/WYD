import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/service/mask/mask_service.dart';
import 'package:wyd_front/state/mask/mask_intervals_cache.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';

class MaskStorageService {
  static Future<void> _addMasks(
    List<RetrieveMaskResponseDto> dtos,
    DateTimeRange dateRange,
  ) async {
    final masks = await Future.wait(dtos.map(_deserializeMask));

    await MaskIntervalsCache().addInterval(dateRange);

    await MaskStorage().saveMultiple(masks, dateRange);
  }

  static Future<Mask> addMask(RetrieveMaskResponseDto dto) async {
    var mask = await _deserializeMask(dto);
    await MaskStorage().saveMask(mask);

    return mask;
  }

  static Future<Mask> _deserializeMask(RetrieveMaskResponseDto dto) async {
    return Mask.fromDto(dto);
  }

  static Future<List<Mask>> retrieveMasksInTimeRange(DateTimeRange requestedInterval) async {
    var missingInterval = MaskIntervalsCache().getMissingInterval(requestedInterval);

    if (missingInterval != null) unawaited(_retrieveFromServer(missingInterval));

    return MaskStorage().getMasksInRange(requestedInterval);
  }

  static Future<void> _retrieveFromServer(DateTimeRange retrieveInterval) async {
    var dtos = await MaskService.retrieveProfileMasks(retrieveInterval);
    await _addMasks(dtos, retrieveInterval);
  }
}
