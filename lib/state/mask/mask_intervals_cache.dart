import 'package:wyd_front/state/mask/mask_intervals_storage.dart';
import 'package:wyd_front/state/util/intervals_cache.dart';

class MaskIntervalsCache extends IntervalsCache<MaskIntervalsStorage> {
  static final MaskIntervalsCache _instance = MaskIntervalsCache._internal(MaskIntervalsStorage());
  factory MaskIntervalsCache() => _instance;
  MaskIntervalsCache._internal(super.storage);
}
