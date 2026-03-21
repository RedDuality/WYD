import 'package:wyd_front/API/Event/retrieve_event_response_dto.dart';
import 'package:wyd_front/API/Event/retrieve_recurrent_event_response_dto.dart';

class RetrieveMultipleEventsResponseDto {
  final List<RetrieveEventResponseDto> events;
  final List<RetrieveRecurrentEventResponseDto> masters;

  RetrieveMultipleEventsResponseDto({
    required this.events,
    required this.masters,
  });

  factory RetrieveMultipleEventsResponseDto.fromJson(Map<String, dynamic> json) {
    return RetrieveMultipleEventsResponseDto(
      events: (json['events'] as List<dynamic>?)
              ?.map((e) => RetrieveEventResponseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <RetrieveEventResponseDto>[],
      masters: (json['masters'] as List<dynamic>?)
              ?.map((e) => RetrieveRecurrentEventResponseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          <RetrieveRecurrentEventResponseDto>[],
    );
  }
}
