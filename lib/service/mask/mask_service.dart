import 'package:flutter/material.dart';
import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/mask_api.dart';
import 'package:wyd_front/API/Mask/retrieve_mask_response_dto.dart';
import 'package:wyd_front/API/Mask/retrieve_multiple_masks_request_dto.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';
import 'package:wyd_front/state/user/user_cache.dart';

class MaskService {
  static Future<String> create(CreateMaskRequestDto createDto) async {
    var createdMaskDto = await MaskAPI().create(createDto);
    var mask = Mask.fromDto(createdMaskDto);
    MaskStorage().saveMask(mask);
    return createdMaskDto.id;
  }

  static Future<List<RetrieveMaskResponseDto>> retrieveFromServer(DateTimeRange retrieveInterval) async {
    var retrieveDto = RetrieveMultipleMasksRequestDto(
        profileHashes: UserCache().getProfileIds(),
        startTime: retrieveInterval.start.toUtc(),
        endTime: retrieveInterval.end.toUtc());

    return await MaskAPI().listMasks(retrieveDto);
  }
}
