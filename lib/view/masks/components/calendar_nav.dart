import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';

class CalendarNav extends StatelessWidget {
  final CalendarController<String> controller;

  const CalendarNav({super.key, required this.controller});

  static const double _btnSize = 40; // matches your IconButton constraints
  static const double _gap = 0;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<DateTimeRange?>(
      valueListenable: controller.visibleDateTimeRange,
      builder: (context, visibleRange, _) {
        bool isTodayVisible = false;
        if (visibleRange != null) {
          final now = DateTime.now();
          isTodayVisible = (now.isAfter(visibleRange.start) || now.isAtSameMomentAs(visibleRange.start)) &&
              now.isBefore(visibleRange.end);
        }

        return SizedBox(
          width: _btnSize*3 + _gap*2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Previous Page',
                constraints: const BoxConstraints(minWidth: _btnSize, minHeight: _btnSize),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_left),
                onPressed: () => controller.animateToPreviousPage(),
              ),
              SizedBox(width: _gap),
              SizedBox(
                width: _btnSize,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: !isTodayVisible
                      ? Tooltip(
                          message: 'Jump to Today',
                          child: IconButton(
                            key: const ValueKey('today_btn'),
                            constraints: const BoxConstraints(minWidth: _btnSize, minHeight: _btnSize),
                            padding: EdgeInsets.zero,
                            icon: const Icon(Icons.today),
                            onPressed: () => controller.jumpToDate(DateTime.now()),
                          ),
                        )
                      : const SizedBox(key: ValueKey('placeholder')),
                ),
              ),
              SizedBox(width: _gap),
              IconButton(
                tooltip: 'Next Page',
                constraints: const BoxConstraints(minWidth: _btnSize, minHeight: _btnSize),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.chevron_right),
                onPressed: () => controller.animateToNextPage(),
              ),
            ],
          ),
        );
      },
    );
  }
}
