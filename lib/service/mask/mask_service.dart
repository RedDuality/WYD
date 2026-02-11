import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/mask_api.dart';
import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_profile_masks_request_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_user_masks_request_dto.dart';
import 'package:wyd_front/API/Mask/update_mask_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class MaskService {
  static Future _addOrUpdate(RetrieveMaskResponseDto maskDto) async {
    var mask = Mask.fromDto(maskDto);
    await MaskStorage().saveMask(mask);
  }

  static Future<String> createMask(CreateMaskRequestDto createDto) async {
    var createdMaskDto = await MaskAPI().create(createDto);
    unawaited(_addOrUpdate(createdMaskDto));
    return createdMaskDto.id;
  }

  static Future<void> update(UpdateMaskRequestDto updateDto) async {
    var updatedMaskDto = await MaskAPI().update(updateDto);
    _addOrUpdate(updatedMaskDto);
  }

  static Future<List<RetrieveMaskResponseDto>> retrieveUserMasks(DateTimeRange retrieveInterval) async {
    var retrieveDto = RetrieveUserMasksRequestDto(
      profileIds: UserCache().getProfileIds(),
      startTime: retrieveInterval.start.toUtc(),
      endTime: retrieveInterval.end.toUtc(),
    );

    return await MaskAPI().retrieveUserMasks(retrieveDto);
  }

  static Future<Set<Mask>> retrieveProfileMasks(
    String profileId,
    DateTimeRange retrieveInterval,
  ) async {
    var retrieveDto = RetrieveProfileMasksRequestDto(
      profileId: profileId,
      startTime: retrieveInterval.start.toUtc(),
      endTime: retrieveInterval.end.toUtc(),
    );

    final viewDtos = await MaskAPI().retrieveProfileMasks(retrieveDto);

    return viewDtos.map((viewDto) => Mask.fromViewDto(viewDto)).toSet();
  }

  static Future _retrieveMask(String maskId) async {
    var maskDto = await MaskAPI().retrieveSingleMask(maskId);
    _addOrUpdate(maskDto);
  }

  static Future<void> checkAndRetrieveUpdates(String maskId, DateTime updatedAt) async {
    var inStorageMask = await MaskStorage().getMaskById(maskId);
    // in case I was the one that updated the mask, it's not necessary to retrieve it
    if (inStorageMask == null || updatedAt.isAfter(inStorageMask.updatedAt)) {
      _retrieveMask(maskId);
    }
  }

  static Future retrieveEventMask(String eventId) async {
    var maskDto = await MaskAPI().retrieveEventMask(eventId);
    _addOrUpdate(maskDto);
  }

  static Future deleteEventMask(String eventId) async {
    await MaskStorage().deleteMaskByEventId(eventId);
  }

  static Future deleteMask(Mask mask) async {}
}
