import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/view/masks/components/calendar_nav.dart';
import 'package:wyd_front/view/masks/detail/mask_detail.dart';
import 'package:wyd_front/view/masks/tiles/mask_tile.dart';
import 'package:wyd_front/view/masks/controllers/mask_view_orchestrator.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/util/add_button.dart';
import '../../../model/util/iterable_extension.dart';

class MaskPage extends StatefulWidget {
  const MaskPage({super.key});

  @override
  State<MaskPage> createState() => _MaskPageState();
}

class _MaskPageState extends State<MaskPage> {
  late final ViewConfiguration _viewConfiguration;

  final CalendarController<String> _calendarController = CalendarController<String>();
  late MaskViewOrchestrator _orchestrator;

  @override
  void initState() {
    super.initState();

    _orchestrator = context.read<MaskViewOrchestrator>();

    final initialRange = _orchestrator.rangeCntrl.currentRange;

    _viewConfiguration = MultiDayViewConfiguration.week(
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
      displayRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 1 * 365)),
        end: DateTime.now().add(Duration(days: 5 * 365)),
      ),
      initialDateTime: initialRange.start,
    );

    _calendarController.visibleDateTimeRange.addListener(_handleUiRangeChange);
  }

  void _handleUiRangeChange() {
    final range = _calendarController.visibleDateTimeRange.value;
    if (range != null) {
      _orchestrator.rangeCntrl.setRange(range);
    }
  }

  @override
  void dispose() {
    _calendarController.visibleDateTimeRange.removeListener(_handleUiRangeChange);
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orchestrator = context.watch<MaskViewOrchestrator>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mask Editor'),
        elevation: 0,
        actions: [
          CalendarNav(controller: _calendarController),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CalendarView<String>(
          key: const ValueKey('editor_calendar'),
          calendarController: _calendarController,
          eventsController: orchestrator.maskCntrl,
          viewConfiguration: _viewConfiguration,
          components: _getCustomComponents(),
          callbacks: _getCallbacks(),
          header: CalendarHeader<String>(),
          body: CalendarBody<String>(
            multiDayTileComponents: TileComponents<String>(
              tileBuilder: (event, tileRange) {
                return MaskTile(event: event);
              },
              tileWhenDraggingBuilder: (event) {
                return MaskTile(event: event, opacity: 0.5);
              },
              feedbackTileBuilder: (event, size) {
                return MaskTile(event: event);
              },
              dropTargetTile: (event) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: AddButton(text: 'Add Mask', child: MaskDetail()),
    );
  }

  // --- Helper Methods ---

  CalendarComponents<String> _getCustomComponents() {
    return CalendarComponents(
      multiDayComponentStyles: MultiDayComponentStyles(
        bodyStyles: MultiDayBodyComponentStyles(
          timelineStyle: TimelineStyle(
            textPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 70), // hide the half and quarter hours
          ),
        ),
      ),
    );
  }

  CalendarCallbacks<String> _getCallbacks() {
    return CalendarCallbacks<String>(
      onEventTapped: _handleEventTapped,
      onEventCreated: (event) => _handleEventCreated,
    );
  }

  void _handleEventCreated(CalendarEvent<String> event, RenderBox renderBox) {
    showCustomDialog(
        context,
        MaskDetail(
          initialDateRange: event.dateTimeRange,
          edit: true,
        ));
  }

  void _handleEventTapped(CalendarEvent<String> event, RenderBox renderBox) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;
    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask != null) {
      showCustomDialog(
          context,
          MaskDetail(
            originalMask: mask,
            edit: true,
          ));
    }
  }
}
