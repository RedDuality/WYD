import 'package:flutter/material.dart';
import 'package:flutter_customizable_calendar/flutter_customizable_calendar.dart';
import 'package:intl/intl.dart';

class MaskView extends StatefulWidget {
  const MaskView({super.key});

  @override
  State<MaskView> createState() => _MaskViewState();
}

class _MaskViewState extends State<MaskView> {

  late final WeekViewController _controller;

  @override
  void initState() {
    _controller = WeekViewController(
      initialDate: DateTime.now());
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WeekView(
      timelineTheme: TimelineTheme(
        cellExtent: 1,
        timeScaleTheme: TimeScaleTheme(
          width: 25,
          drawQuarterHourMarks: false,
          drawHalfHourMarks: false,
          hourFormatter: (DateTime value) => DateFormat.H().format(value),
        )),
      controller: _controller,
      
      events: [
        SimpleAllDayEvent(
          id: 'All-day 1',
          start: DateTime.now(),
          duration: const Duration(days: 2),
          title: 'Prova 1',
          color: Colors.redAccent.shade200,
        ),
      ],
    );
  }
}
