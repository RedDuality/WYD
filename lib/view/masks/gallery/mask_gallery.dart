import 'package:flutter/material.dart';
import 'package:kalender/kalender.dart';
import 'package:provider/provider.dart';
import 'package:wyd_front/model/profiles/profile.dart';
import 'package:wyd_front/state/mask/mask_cache.dart';
import 'package:wyd_front/state/mask/mask_controller.dart';
import 'package:wyd_front/state/profile/profiles_cache.dart';
import 'package:wyd_front/view/masks/controllers/mask_gallery_orchestrator.dart';
import 'package:wyd_front/view/masks/controllers/mask_range_controller.dart';
import 'package:wyd_front/view/masks/detail/mask_detail.dart';
import 'package:wyd_front/view/masks/tiles/mask_tile.dart';
import 'package:wyd_front/view/widget/dialog/custom_dialog.dart';
import 'package:wyd_front/view/widget/util/add_button.dart';
import '../../../model/util/iterable_extension.dart';

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
        title: Text('${profile!.name}\'s Agenda'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _calendarController.animateToPreviousPage(),
            tooltip: 'Previous Week',
          ),
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () => _calendarController.jumpToDate(DateTime.now()),
            tooltip: 'Today',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _calendarController.animateToNextPage(),
            tooltip: 'Next Week',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: CalendarView<String>(
          key: const ValueKey('gallery_calendar'),
          calendarController: _calendarController,
          eventsController: _orchestrator.maskCntrl,
          viewConfiguration: _viewConfiguration,
          components: _getCustomComponents(),
          callbacks: CalendarCallbacks<String>(onEventTapped: _handleEventTapped),
          header: CalendarHeader<String>(),
          body: CalendarBody<String>(
            multiDayTileComponents: TileComponents<String>(
              tileBuilder: (event, tileRange) {
                return MaskTile(event: event);
              },
            ),
          ),
        ),
      ),
      // TODO
      floatingActionButton: AddButton(text: 'Plan a visit!', child: MaskDetail()),
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

  void _handleEventTapped(CalendarEvent<String> event, RenderBox renderBox) {
    final maskCache = Provider.of<MaskCache>(context, listen: false);
    final maskId = event.data;
    final mask = maskCache.allMasks.firstWhereOrNull((m) => m.id == maskId);

    if (mask != null) {
      // TODO
      showCustomDialog(context, MaskDetail(originalMask: mask));
    }
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
}
