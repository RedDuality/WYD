import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/profiles/profile.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/state/profile/profiles_cache.dart';
import 'package:wyd_front/view/masks/components/calendar_nav.dart';
import 'package:wyd_front/view/masks/controllers/mask_gallery_orchestrator.dart';
import 'package:wyd_front/view/masks/controllers/mask_range_controller.dart';
import 'package:wyd_front/view/masks/detail/mask_detail.dart';
import 'package:wyd_front/view/masks/tiles/mask_tile.dart';
import 'package:wyd_front/view/widget/button/exit_button.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/util/add_button.dart';

class MaskGallery extends StatefulWidget {
  final String profileId;
  const MaskGallery({super.key, required this.profileId});

  @override
  State<MaskGallery> createState() => _MaskGalleryState();
}

class _MaskGalleryState extends State<MaskGallery> {
  late final Profile? profile;
  late final ViewConfiguration _viewConfiguration;

  final CalendarController<String> _calendarController = CalendarController<String>();
  late MaskGalleryOrchestrator _orchestrator;

  bool _isOrchestratorInitialized = false;

  @override
  void initState() {
    super.initState();

    _viewConfiguration = MultiDayViewConfiguration.week(
      initialTimeOfDay: const TimeOfDay(hour: 7, minute: 0),
      displayRange: DateTimeRange(
        start: DateTime.now().subtract(Duration(days: 1 * 365)),
        end: DateTime.now().add(Duration(days: 5 * 365)),
      ),
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
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isOrchestratorInitialized) {
      // This runs after initState but BEFORE the first build
      _initializeOrchestrator();
    }
  }

  void _initializeOrchestrator() {
    final rangeController = MaskRangeController(
      initialDate: DateTime.now(),
      numberOfDays: 7,
    );

    _orchestrator = MaskGalleryOrchestrator(
      maskController: MaskController(null),
      rangeController: rangeController,
      profileId: widget.profileId,
    );

    _orchestrator.initialize();
    _isOrchestratorInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    profile = context.read<ProfileCache>().get(widget.profileId);
    if (profile == null) {
      return Center(
        child: Text("There was an error while retrieving profile data"),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    width: constraints.maxWidth * 0.33,
                    child: Text(
                      '${profile!.name}\'s Agenda',
                      style: const TextStyle(fontSize: 20),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                  ),
                ),
                CalendarNav(controller: _calendarController),
              ],
            );
          },
        ),
        actions: [const ExitButton()],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CalendarView<String>(
          key: const ValueKey('gallery_calendar'),
          calendarController: _calendarController,
          eventsController: _orchestrator.maskCntrl,
          viewConfiguration: _viewConfiguration,
          components: _getCustomComponents(),
          callbacks: _getCallbacks(),
          header: CalendarHeader<String>(),
          body: CalendarBody<String>(
            interaction: CalendarInteraction(
              allowResizing: false,
              allowRescheduling: false,
              allowEventCreation: true,
              createEventGesture: null,
              modifyEventGesture: null,
            ),
            multiDayTileComponents: TileComponents<String>(
              tileBuilder: (event, tileRange) {
                return MaskTile(event: event);
              },
              tileWhenDraggingBuilder: (event) {
                return MaskTile(event: event, opacity: 0.5);
              },
              /*
              feedbackTileBuilder: (event, size) {
                return MaskTile(event: event);
              },*/
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
      floatingActionButton: AddButton(
          text: 'Plan a meeting!',
          child: MaskDetail(
            edit: true,
            propose: true,
          )),
    );
  } // build

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
      onEventCreated: _handleEventCreated,
      onEventTapped: _handleEventTapped,
    );
  }

  void _handleEventCreated(CalendarEvent<String> event) {
    showCustomDialog(
      context,
      MaskDetail(
        initialDateRange: event.dateTimeRange,
        edit: true,
        propose: true,
      ),
    );
  }

  void _handleEventTapped(CalendarEvent<String> event, RenderBox renderBox) {
    showCustomDialog(context, MaskDetail(initialDateRange: event.dateTimeRange));
  }

  @override
  void dispose() {
    _calendarController.visibleDateTimeRange.removeListener(_handleUiRangeChange);
    _calendarController.dispose();
    super.dispose();
  }
}
