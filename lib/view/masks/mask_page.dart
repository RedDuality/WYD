import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/mask/mask.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/view/masks/editor/mask_editor.dart';
import 'package:wyd_front/view/masks/mask_range_controller.dart';
import 'package:wyd_front/view/masks/mask_tile.dart';
import 'package:wyd_front/view/masks/mask_view_orchestrator.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/util/add_button.dart';

import '../../model/util/iterable_extension.dart';

class MaskPage extends StatefulWidget {
  const MaskPage({super.key});

  @override
  State<MaskPage> createState() => _MaskPageState();
}

class _MaskPageState extends State<MaskPage> {

  late final MaskViewOrchestrator _viewOrchestrator;

  late final CalendarController<String> _calendarController;
  late final ViewConfiguration _viewConfiguration;

  late final CalendarComponents<String> _customComponents;

  @override
  void initState() {
    super.initState();

    _customComponents = _getCustomComponents();

    _calendarController = CalendarController<String>();
    _viewConfiguration = MultiDayViewConfiguration.week(
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
    );

    final viewController = _calendarController.viewController as MultiDayViewController;
    final maskCache = context.read<MaskCache>();

    final rangeController = MaskRangeController(
      viewController,
      initialDate: DateTime.now(),
      numberOfDays: 7,
    );

    _viewOrchestrator = MaskViewOrchestrator(
      maskCache: maskCache,
      maskController: MaskController(),
      rangeController: rangeController,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewOrchestrator.initialize();
    });
  }

  // edit the timeline
  CalendarComponents<String> _getCustomComponents(){
    return CalendarComponents(
      multiDayComponents: MultiDayComponents(
        bodyComponents: MultiDayBodyComponents(
          timeline: (heightPerMinute, timeOfDayRange, style, eventBeingDragged, visibleDateTimeRange) {
            return TimeLine(
              heightPerMinute: heightPerMinute,
              timeOfDayRange: timeOfDayRange,
              style: TimelineStyle(
                // Customize hour format here
                stringBuilder: (timeOfDay) {
                  // Show only hours in 24h format with leading zero
                  //return timeOfDay.hour.toString().padLeft(2, '0');

                  // Alternative formats: 
                  // 1.Show only hour without leading zero: 
                  return '${timeOfDay.hour}';

                  // 2.Show in 12h format with AM/PM:
                  // final hour12 = timeOfDay. hourOfPeriod == 0 ? 12 :   timeOfDay.hourOfPeriod;
                  // final period = timeOfDay.period == DayPeriod.am ? 'AM' : 'PM';
                  // return '$hour12 $period';

                  // 3.Show hour with a custom suffix:
                  // return '${timeOfDay.hour}h';
                },
              ),
              eventBeingDragged: eventBeingDragged,
              visibleDateTimeRange: visibleDateTimeRange,
            );
          },
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _calendarController.dispose();
    _viewOrchestrator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewOrchestrator,
      child:  Scaffold(
        appBar: AppBar(
          title: const Text('Mask Editor'),
          elevation: 0,
          actions: [],
        ),
        body: Consumer<MaskViewOrchestrator>(
          builder: (context, orchestrator, child) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: CalendarView<String>(
                calendarController: _calendarController,
                eventsController: orchestrator.maskCntrl,
                viewConfiguration: _viewConfiguration,
                components: _customComponents,
                callbacks: CalendarCallbacks<String>(
                  onEventTapped: _handleEventTapped,
                  // Only allow tap detail on existing events, not empty space
                  onTappedWithDetail: (detail) {
                    // Check if it's actually on an event or just empty space
                    // For now, we'll comment this out to allow page swiping
                    // _handleTapDetail(detail);
                  },
                  // Only allow long press on existing events
                  onLongPressedWithDetail: (detail) {
                    // Comment out to allow page swiping
                    // _handleLongPressDetail(detail);
                  },
                ),
                body: CalendarBody<String>(
                  multiDayTileComponents: TileComponents<String>(
                    tileBuilder: (event, tileRange) => _buildMaskTile(context, event),
                    tileWhenDraggingBuilder: (event) => _buildMaskTile(context, event, opacity: 0.5),
                    feedbackTileBuilder: (event, size) => _buildMaskTile(context, event),
                    dropTargetTile: (event) => Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        floatingActionButton: AddButton(text: 'Add Mask', child: MaskEditor()),
      ),
    );
  }

  /// Build the mask tile by looking up the mask from cache using the event's data (mask ID)
  Widget _buildMaskTile(BuildContext context, CalendarEvent<String> event, {double opacity = 1.0}) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;

    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask == null) {
      return const SizedBox.shrink();
    }

    return MaskTile(event: event, maskData: mask, opacity: opacity);
  }

  void _handleEventTapped(CalendarEvent<String> event, RenderBox renderBox) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;
    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask != null) {
      _showEditMaskDialog(mask);
    }
  }




  void _showEditMaskDialog(Mask mask) {
    showCustomDialog(context, MaskEditor(originalMask: mask));
  }
}