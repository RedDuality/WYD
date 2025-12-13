import 'package:wyd_front/API/Mask/create_mask_request_dto.dart';
import 'package:wyd_front/API/Mask/mask_api.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/state/mask/mask_storage.dart';

class MaskService {
  static Future<String> create(CreateMaskRequestDto createDto) async {
    var createdMaskDto = await MaskAPI().create(createDto);
    var mask = Mask.fromDto(createdMaskDto);
    MaskStorage().saveMask(mask);
    return createdMaskDto.id;
  }
}
