import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:wyd_front/view/masks/mask_page.dart';

class MaskPreview extends StatelessWidget {
  const MaskPreview({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Calendar setup
    final eventsController = DefaultEventsController();
    final calendarController = CalendarController();

    void addEvents() {
      final now = DateTime.now();
      eventsController.addEvent(CalendarEvent(
        dateTimeRange: DateTimeRange(
          start: now,
          end: now.add(const Duration(hours: 1)),
        ),
        data: "Event 1",
      ));
    }

    final configuration = MultiDayViewConfiguration.week(
      initialHeightPerMinute: 0.3,
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
    );

    addEvents();

    // 2. The main container for clickable design
    return Card(
      elevation: 4, // Adds a subtle shadow (affordance)
      clipBehavior: Clip.antiAlias, // Clips content to rounded corners
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // The parent InkWell catches taps on the Card's margins/borders
        onTap: () => _goToEditor(context),
        child: Stack(
          children: [
            // 3. The Calendar View
            // Horizontal scrolling is now allowed since IgnorePointer was removed.
            CalendarView(
              eventsController: eventsController,
              calendarController: calendarController,
              viewConfiguration: configuration,
              // Callbacks are configured to trigger _goToEditor on any tap.
              callbacks: _getClickableCallbacks(context),
              header: CalendarHeader(),
              body: CalendarBody(
                // Ensure interactions like resizing/creation are disabled
                interaction: ValueNotifier(
                  CalendarInteraction(
                    allowResizing: false,
                    allowRescheduling: false,
                    allowEventCreation: false,
                  ),
                ),
                multiDayTileComponents: TileComponents(
                  tileBuilder: (mask, tileRange) => Container(),
                  tileWhenDraggingBuilder: (mask) => Container(),
                  feedbackTileBuilder: (mask, size) => Container(),
                  dropTargetTile: (mask) => Container(),
                ),
              ),
            ),

            // 4. Subtle Edit Icon Overlay
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Callbacks and Navigation ---

  // Function to navigate to the editor page
  void _goToEditor(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MaskPage()),
    );
  }

  // Configures the Kalender callbacks to trigger navigation on taps/long presses.
  CalendarCallbacks _getClickableCallbacks(BuildContext context) {
    // 1. Handle taps on existing events (fixes the type error)
    void handleEventTap(CalendarEvent<Object?> event, RenderBox renderBox) {
      _goToEditor(context);
    }

    // 2. Handle taps on empty slots (uses DateTime parameter)
    void handleSlotTap(DateTime dateTime) {
      _goToEditor(context);
    }

    return CalendarCallbacks(
      // Tapping an empty slot triggers navigation
      onTapped: handleSlotTap,

      // Tapping an existing event triggers navigation
      onEventTapped: handleEventTap,

      // Long pressing on an empty slot triggers navigation
      onLongPressed: handleSlotTap,

      // Explicitly disable other interactive gestures to keep it a preview
      onTappedWithDetail: null,
      onLongPressedWithDetail: null,
      onEventTappedWithDetail: null,
      onEventCreate: null,
      onEventChanged: null,
      onPageChanged: null,
      onEventCreated: null,
    );
  }
}
